import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import 'arabic.dart';

/// Entries per solid deflate block in the on-device database.
const int kChunkSize = 512;

/// Bumped when the container format or the database layout changes.
const int kCorpusVersion = 3;

const List<int> _magic = [0x51, 0x41, 0x4D, 0x55, 0x53, 0x33, 0x00]; // QAMUS3\0

/// Reads the columnar corpus container produced by `tools/build_db.py`.
///
/// The container stores each column as one contiguous run — every word length,
/// then every definition length, then all the headwords, then all the
/// definitions — because that is what lets xz compress 55.8 MB down to 10.
class _Reader {
  _Reader(this.bytes, [this.offset = 0]);

  final Uint8List bytes;
  int offset;

  int u32() {
    final value = bytes.buffer.asByteData().getUint32(
      bytes.offsetInBytes + offset,
      Endian.little,
    );
    offset += 4;
    return value;
  }

  /// LEB128: small lengths and ids cost one byte and compress to less.
  int varint() {
    var value = 0;
    var shift = 0;
    while (true) {
      final byte = bytes[offset++];
      value |= (byte & 0x7F) << shift;
      if (byte & 0x80 == 0) return value;
      shift += 7;
    }
  }

  String text() {
    final length = varint();
    final out = utf8.decode(
      Uint8List.sublistView(bytes, offset, offset + length),
    );
    offset += length;
    return out;
  }

  /// A length-prefixed run, returned as a view rather than a copy.
  Uint8List section() {
    final length = u32();
    final out = Uint8List.sublistView(bytes, offset, offset + length);
    offset += length;
    return out;
  }
}

/// What the caller is told while the database is being assembled.
enum BuildStage { writing, indexing }

/// Turns the shipped container into the SQLite database the app queries.
///
/// This runs once per install. It does three things the container deliberately
/// leaves undone, because each is cheaper to recompute than to download:
///
///  * derives the normalised search key and its reversal for every headword;
///  * packs the definitions into deflate blocks, so the finished database is
///    37 MB on disk rather than 65 MB, and one lookup inflates one block;
///  * builds the four indexes the search modes run on.
void buildDatabase(
  Uint8List container,
  String path,
  void Function(double fraction, BuildStage stage) report,
) {
  for (var i = 0; i < _magic.length; i++) {
    if (container[i] != _magic[i]) {
      throw const FormatException('not a qamus corpus');
    }
  }

  final head = _Reader(container, _magic.length);
  final count = head.u32();
  final bookCount = head.u32();
  final rootCount = head.u32();
  final formCount = head.u32();

  final books = <(String, String)>[
    for (var i = 0; i < bookCount; i++) (head.text(), head.text()),
  ];

  final rootReader = _Reader(head.section());
  final roots = <String>[for (var i = 0; i < rootCount; i++) rootReader.text()];

  final wordLens = _Reader(head.section());
  final defLens = _Reader(head.section());
  final rootIds = _Reader(head.section());
  final bookIds = head.section();
  final wordsBlob = head.section();
  final defsBlob = head.section();
  final formLens = _Reader(head.section());
  final formsBlob = head.section();
  final linkCounts = _Reader(head.section());
  final linkIds = _Reader(head.section());

  final file = File(path);
  if (file.existsSync()) file.deleteSync();
  file.parent.createSync(recursive: true);
  for (final suffix in const ['-journal', '-wal', '-shm']) {
    final side = File('$path$suffix');
    if (side.existsSync()) side.deleteSync();
  }

  final db = sqlite3.open(path);
  try {
    db
      ..execute('PRAGMA journal_mode = OFF')
      ..execute('PRAGMA synchronous = OFF')
      ..execute('PRAGMA temp_store = MEMORY')
      ..execute('PRAGMA cache_size = -32000')
      ..execute('PRAGMA page_size = 4096');

    db.execute('''
      CREATE TABLE meta   (k TEXT PRIMARY KEY, v TEXT);
      CREATE TABLE books  (id INTEGER PRIMARY KEY, name TEXT NOT NULL,
                           dict TEXT, n INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE roots  (id INTEGER PRIMARY KEY, r TEXT NOT NULL);
      CREATE TABLE entries(id INTEGER PRIMARY KEY, w TEXT NOT NULL,
                           rid INTEGER, b INTEGER NOT NULL,
                           k TEXT NOT NULL, kr TEXT NOT NULL);
      CREATE TABLE chunks (id INTEGER PRIMARY KEY, z BLOB NOT NULL);
      -- The source's morphological lookup index: a surface form (a plural, a
      -- conjugation, a definite form) mapped to the headwords that explain
      -- it. Two thirds of these forms are not headwords themselves.
      CREATE TABLE forms (id INTEGER PRIMARY KEY, f TEXT NOT NULL,
                          fr TEXT NOT NULL);
      CREATE TABLE links (fid INTEGER NOT NULL, hk TEXT NOT NULL);
    ''');

    db.execute('BEGIN');

    final insertBook = db.prepare(
      'INSERT INTO books(id,name,dict) VALUES (?,?,?)',
    );
    for (var i = 0; i < books.length; i++) {
      insertBook.execute([i + 1, books[i].$1, books[i].$2]);
    }
    insertBook.dispose();

    final insertRoot = db.prepare('INSERT INTO roots(id,r) VALUES (?,?)');
    for (var i = 0; i < roots.length; i++) {
      insertRoot.execute([i + 1, roots[i]]);
    }
    insertRoot.dispose();

    final insertEntry = db.prepare(
      'INSERT INTO entries(id,w,rid,b,k,kr) VALUES (?,?,?,?,?,?)',
    );
    final insertChunk = db.prepare('INSERT INTO chunks(id,z) VALUES (?,?)');

    // Definitions are deflated, not stored raw: dart:io exposes zlib natively,
    // so a block costs about a millisecond to inflate and needs no package.
    final codec = ZLibCodec(level: 6);
    final pending = BytesBuilder(copy: false);
    var pendingCount = 0;
    var chunkId = 0;

    void flush() {
      if (pendingCount == 0) return;
      insertChunk.execute([chunkId++, codec.encode(pending.takeBytes())]);
      pendingCount = 0;
    }

    // Filled as entries are written, then read back by the form index. The
    // builder ships an entry id per link rather than a headword string, so a
    // drift between the two normalisers cannot produce a broken link.
    final entryKeys = List<String>.filled(count, '');

    var wordAt = 0;
    var defAt = 0;
    for (var i = 0; i < count; i++) {
      final wordLen = wordLens.varint();
      final defLen = defLens.varint();
      final rootId = rootIds.varint();

      final word = utf8.decode(
        Uint8List.sublistView(wordsBlob, wordAt, wordAt + wordLen),
      );
      wordAt += wordLen;

      final key = normalize(word);
      entryKeys[i] = key;
      insertEntry.execute([
        i,
        word,
        rootId == 0 ? null : rootId,
        bookIds[i] + 1,
        key,
        reverseKey(key),
      ]);

      if (pendingCount > 0) pending.addByte(0);
      pending.add(Uint8List.sublistView(defsBlob, defAt, defAt + defLen));
      defAt += defLen;
      pendingCount++;
      if (pendingCount == kChunkSize) flush();

      if (i % 8192 == 0) report(i / count, BuildStage.writing);
    }
    flush();

    insertEntry.dispose();
    insertChunk.dispose();

    _writeForms(
      db: db,
      formCount: formCount,
      formLens: formLens,
      formsBlob: formsBlob,
      linkCounts: linkCounts,
      linkIds: linkIds,
      entryKeys: entryKeys,
      report: report,
    );

    db.execute(
      'UPDATE books SET n = (SELECT COUNT(*) FROM entries WHERE entries.b = books.id)',
    );
    final insertMeta = db.prepare('INSERT INTO meta(k,v) VALUES (?,?)');
    for (final pair in [
      ('schema', '$kCorpusVersion'),
      ('chunk', '$kChunkSize'),
      ('entries', '$count'),
      ('source', 'Almaany Ar-Ar v11'),
    ]) {
      insertMeta.execute([pair.$1, pair.$2]);
    }
    insertMeta.dispose();
    db.execute('COMMIT');

    report(0, BuildStage.indexing);
    db.execute('CREATE INDEX i_entries_k ON entries(k)');
    db.execute('CREATE INDEX i_forms_f ON forms(f)');
    db.execute('CREATE INDEX i_forms_fr ON forms(fr)');
    db.execute('CREATE INDEX i_links_fid ON links(fid)');
    report(0.35, BuildStage.indexing);
    db.execute('CREATE INDEX i_entries_kr ON entries(kr)');
    report(0.7, BuildStage.indexing);
    db.execute('CREATE INDEX i_entries_rid ON entries(rid)');
    db.execute('CREATE INDEX i_roots_r ON roots(r)');
    report(0.9, BuildStage.indexing);
    db.execute('ANALYZE');
    report(1, BuildStage.indexing);
  } finally {
    db.dispose();
  }
}

/// Writes the lookup forms and their links to the headwords they explain.
///
/// Each form is re-normalised on the way in, so everything the app queries is
/// in *this* normaliser's shape whatever the builder used. Forms that collapse
/// onto one another after that merge rather than duplicate.
void _writeForms({
  required Database db,
  required int formCount,
  required _Reader formLens,
  required Uint8List formsBlob,
  required _Reader linkCounts,
  required _Reader linkIds,
  required List<String> entryKeys,
  required void Function(double, BuildStage) report,
}) {
  final insertForm = db.prepare('INSERT INTO forms(id,f,fr) VALUES (?,?,?)');
  final insertLink = db.prepare('INSERT INTO links(fid,hk) VALUES (?,?)');

  final formIds = <String, int>{};
  final written = <int, Set<String>>{};
  var formAt = 0;
  var nextId = 0;

  for (var i = 0; i < formCount; i++) {
    final length = formLens.varint();
    final raw = utf8.decode(
      Uint8List.sublistView(formsBlob, formAt, formAt + length),
    );
    formAt += length;

    final linkCount = linkCounts.varint();
    final targets = <String>[];
    var entryId = 0;
    for (var j = 0; j < linkCount; j++) {
      entryId += linkIds.varint(); // delta-coded within each form
      if (entryId >= 0 && entryId < entryKeys.length) {
        final key = entryKeys[entryId];
        if (key.isNotEmpty) targets.add(key);
      }
    }

    final form = normalize(raw);
    if (form.isEmpty || targets.isEmpty) continue;

    final id = formIds.putIfAbsent(form, () {
      final assigned = nextId++;
      insertForm.execute([assigned, form, reverseKey(form)]);
      written[assigned] = <String>{};
      return assigned;
    });

    final seen = written[id]!;
    for (final key in targets) {
      if (seen.add(key)) insertLink.execute([id, key]);
    }

    if (i % 8192 == 0) report(i / formCount, BuildStage.writing);
  }

  insertForm.dispose();
  insertLink.dispose();
}
