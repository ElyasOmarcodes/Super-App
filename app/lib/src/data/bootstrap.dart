import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'arabic.dart';
import 'corpus.dart';
import 'vault.dart';

const String kCorpusAsset = 'assets/db/qamus.corpus.sealed';
const String kDbFileName = 'qamus.db';

enum BootstrapStage { idle, unpacking, writing, indexing, ready, failed }

@immutable
class BootstrapProgress {
  const BootstrapProgress(this.stage, this.fraction, {this.message});

  final BootstrapStage stage;

  /// 0..1, or -1 when the step cannot report a meaningful fraction.
  final double fraction;
  final String? message;
}

class _Job {
  const _Job(this.sendPort, this.compressed, this.targetPath);

  final SendPort sendPort;
  final Uint8List compressed;
  final String targetPath;
}

/// Unpacks the shipped corpus and assembles the database the app queries.
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

  String get _stamp => '$kCorpusVersion.$kNormalizerVersion';

  Future<bool> _isPrepared(String dbPath) async {
    if (!File(dbPath).existsSync()) return false;
    final stamp = await _stampFile();
    if (!stamp.existsSync()) return false;
    return stamp.readAsStringSync().trim() == _stamp;
  }

  /// Returns the path of a database that is ready to be queried.
  Future<String> ensureReady() async {
    final dbPath = await databasePath();
    if (await _isPrepared(dbPath)) {
      _controller.add(const BootstrapProgress(BootstrapStage.ready, 1));
      return dbPath;
    }

    _controller.add(const BootstrapProgress(BootstrapStage.unpacking, -1));
    final data = await rootBundle.load(kCorpusAsset);
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
        if (!completer.isCompleted) completer.complete(message);
      } else if (message is List && message.length == 2) {
        if (!completer.isCompleted) {
          completer.completeError(
            message[0] as Object,
            StackTrace.fromString('${message[1]}'),
          );
        }
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
      stamp.writeAsStringSync(_stamp);
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
    // Unseal, then inflate. Both run here, in the worker isolate, so neither
    // the key derivation nor the decompression touches the frame the splash
    // screen is drawing.
    final archive = CorpusVault.open(job.compressed, corpusPassphrase());
    final container = Uint8List.fromList(XZDecoder().decodeBytes(archive));

    buildDatabase(container, job.targetPath, (fraction, stage) {
      send.send(
        BootstrapProgress(
          stage == BuildStage.writing
              ? BootstrapStage.writing
              : BootstrapStage.indexing,
          fraction,
        ),
      );
    });

    send.send(job.targetPath);
  } catch (error, stack) {
    send.send([error.toString(), stack.toString()]);
  }
}
