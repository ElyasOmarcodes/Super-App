import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'arabic.dart';

const String kDbAsset = 'assets/db/qamus.db.xz';
const String kDbFileName = 'qamus.db';

/// Bumped whenever the shipped asset or the on-device preparation changes;
/// a mismatch makes the app rebuild its working copy from the asset.
const int kDbBuildVersion = 1;

enum BootstrapStage { idle, unpacking, writing, indexing, ready, failed }

@immutable
class BootstrapProgress {
  const BootstrapProgress(this.stage, this.fraction, {this.message});

  final BootstrapStage stage;

  /// 0..1, or -1 when the step cannot report a meaningful fraction.
  final double fraction;
  final String? message;

  String get title => switch (stage) {
    BootstrapStage.unpacking => 'جارٍ فكّ ضغط المعجم',
    BootstrapStage.writing => 'جارٍ تجهيز قاعدة البيانات',
    BootstrapStage.indexing => 'جارٍ بناء فهارس البحث',
    BootstrapStage.ready => 'جاهز',
    BootstrapStage.failed => 'تعذّر التجهيز',
    BootstrapStage.idle => 'لحظة من فضلك',
  };
}

/// Message passed into the worker isolate.
class _Job {
  const _Job(this.sendPort, this.compressed, this.targetPath);

  final SendPort sendPort;
  final Uint8List compressed;
  final String targetPath;
}

/// Unpacks the shipped `.xz` database and materialises everything that was
/// deliberately left out of the asset to keep it small: the normalised search
/// key, its reversal, and the three indexes the app searches through.
///
/// The whole thing runs in a background isolate so the setup screen keeps
/// animating, and it only ever happens once per install.
class DatabaseBootstrap {
  DatabaseBootstrap();

  final _controller = StreamController<BootstrapProgress>.broadcast();
  Stream<BootstrapProgress> get progress => _controller.stream;

  Future<String> databasePath() async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, kDbFileName);
  }

  Future<File> _stampFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, '.qamus-build'));
  }

  Future<bool> _isPrepared(String dbPath) async {
    if (!File(dbPath).existsSync()) return false;
    final stamp = await _stampFile();
    if (!stamp.existsSync()) return false;
    return stamp.readAsStringSync().trim() ==
        '$kDbBuildVersion.$kNormalizerVersion';
  }

  /// Returns the path of a database that is ready to be queried.
  Future<String> ensureReady() async {
    final dbPath = await databasePath();
    if (await _isPrepared(dbPath)) {
      _controller.add(const BootstrapProgress(BootstrapStage.ready, 1));
      return dbPath;
    }

    _controller.add(const BootstrapProgress(BootstrapStage.unpacking, -1));
    final data = await rootBundle.load(kDbAsset);
    final compressed = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final receive = ReceivePort();
    final completer = Completer<String>();
    late Isolate isolate;

    receive.listen((dynamic message) {
      if (message is BootstrapProgress) {
        _controller.add(message);
      } else if (message is String) {
        completer.complete(message);
      } else if (message is List && message.length == 2) {
        completer.completeError(
          message[0] as Object,
          StackTrace.fromString('${message[1]}'),
        );
      }
    });

    isolate = await Isolate.spawn(
      _worker,
      _Job(receive.sendPort, Uint8List.fromList(compressed), dbPath),
      onError: receive.sendPort,
      debugName: 'qamus-bootstrap',
    );

    try {
      final path = await completer.future;
      final stamp = await _stampFile();
      stamp.writeAsStringSync('$kDbBuildVersion.$kNormalizerVersion');
      _controller.add(const BootstrapProgress(BootstrapStage.ready, 1));
      return path;
    } catch (error) {
      _controller.add(
        BootstrapProgress(BootstrapStage.failed, 0, message: '$error'),
      );
      rethrow;
    } finally {
      receive.close();
      isolate.kill(priority: Isolate.beforeNextEvent);
    }
  }

  void dispose() => _controller.close();
}

void _worker(_Job job) {
  final send = job.sendPort;
  try {
    send.send(const BootstrapProgress(BootstrapStage.unpacking, -1));
    final raw = XZDecoder().decodeBytes(job.compressed);

    send.send(const BootstrapProgress(BootstrapStage.writing, -1));
    final target = File(job.targetPath);
    if (target.existsSync()) target.deleteSync();
    target.parent.createSync(recursive: true);
    // Clear stale sidecars from an interrupted earlier run.
    for (final suffix in const ['-journal', '-wal', '-shm']) {
      final side = File('${job.targetPath}$suffix');
      if (side.existsSync()) side.deleteSync();
    }
    target.writeAsBytesSync(raw, flush: true);

    prepareDatabase(
      job.targetPath,
      (fraction, stage) => send.send(BootstrapProgress(stage, fraction)),
    );

    send.send(job.targetPath);
  } catch (error, stack) {
    send.send([error.toString(), stack.toString()]);
  }
}

/// Fills `entries.k` / `entries.kr` and builds the search indexes.
///
/// Kept as a top-level function so it can be exercised directly from tests.
void prepareDatabase(
  String path,
  void Function(double, BootstrapStage) report,
) {
  final db = sqlite3.open(path);
  try {
    db
      ..execute('PRAGMA journal_mode = OFF')
      ..execute('PRAGMA synchronous = OFF')
      ..execute('PRAGMA temp_store = MEMORY')
      ..execute('PRAGMA cache_size = -32000');

    final total =
        db.select('SELECT COUNT(*) AS n FROM entries').first['n'] as int;
    report(0, BootstrapStage.writing);

    final rows = db.select('SELECT id, w FROM entries');
    final update = db.prepare('UPDATE entries SET k = ?, kr = ? WHERE id = ?');
    db.execute('BEGIN');
    var done = 0;
    for (final row in rows) {
      final key = normalize(row['w'] as String);
      update.execute([key, reverseKey(key), row['id']]);
      done++;
      if (done % 8192 == 0) report(done / total * 0.75, BootstrapStage.writing);
    }
    db.execute('COMMIT');
    update.dispose();

    report(0, BootstrapStage.indexing);
    db.execute('CREATE INDEX IF NOT EXISTS i_entries_k ON entries(k)');
    report(0.35, BootstrapStage.indexing);
    db.execute('CREATE INDEX IF NOT EXISTS i_entries_kr ON entries(kr)');
    report(0.7, BootstrapStage.indexing);
    db.execute('CREATE INDEX IF NOT EXISTS i_entries_rid ON entries(rid)');
    db.execute('CREATE INDEX IF NOT EXISTS i_roots_r ON roots(r)');
    report(0.9, BootstrapStage.indexing);
    db.execute('ANALYZE');
    report(1, BootstrapStage.indexing);
  } finally {
    db.dispose();
  }
}
