import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import 'arabic.dart';
import 'models.dart';

/// Read-only access to the packed dictionary.
///
/// Definitions live in solid deflate blocks of [_chunkSize] entries, so a
/// lookup inflates one block and slices out the row it needs.  A small LRU
/// keeps the last few blocks around, which makes browsing a root — where hits
/// cluster in the same block — essentially free.
class Dictionary {
  Dictionary._(this._db, this._chunkSize, this.books);

  final Database _db;
  final int _chunkSize;
  final List<Book> books;

  late final Map<int, Book> _booksById = {for (final b in books) b.id: b};

  final _chunkCache = <int, List<String>>{};
  static const _maxCachedChunks = 6;

  static Future<Dictionary> open(String path) async {
    final db = sqlite3.open(path, mode: OpenMode.readWrite);
    db
      ..execute('PRAGMA journal_mode = OFF')
      ..execute('PRAGMA synchronous = OFF')
      ..execute('PRAGMA cache_size = -8000')
      ..execute('PRAGMA temp_store = MEMORY');

    final chunk = int.parse(
      db.select("SELECT v FROM meta WHERE k = 'chunk'").first['v'] as String,
    );
    final books = db
        .select('SELECT id, name, dict, n FROM books ORDER BY n DESC')
        .map(
          (r) => Book(
            id: r['id'] as int,
            name: r['name'] as String,
            dict: (r['dict'] as String?) ?? '',
            count: r['n'] as int,
          ),
        )
        .toList(growable: false);
    return Dictionary._(db, chunk, books);
  }

  String get path => _db.select('PRAGMA database_list').first['file'] as String;

  Book? book(int id) => _booksById[id];

  int get entryCount =>
      _db.select('SELECT COUNT(*) AS n FROM entries').first['n'] as int;

  int get rootCount =>
      _db.select('SELECT COUNT(*) AS n FROM roots').first['n'] as int;

  void dispose() {
    _chunkCache.clear();
    _db.dispose();
  }

  // ------------------------------------------------------------------ search

  /// A `b IN (...)` fragment, or an empty string when every book is enabled.
  String _bookFilter(Set<int> enabled) {
    if (enabled.isEmpty || enabled.length == books.length) return '';
    return ' AND b IN (${enabled.join(',')})';
  }

  /// Live suggestions and full result lists share this one path.
  ///
  /// Searching runs over the **lookup forms**, not the headwords: two thirds
  /// of the forms the source knows — plurals, conjugations, definite forms —
  /// are not headwords themselves, so a headword-only search cannot find
  /// them. `مهابل` resolves to the entry for `مهبل`; `الرحيم` and `رحيم`
  /// resolve to each other, which is what makes the article transparent.
  List<Headword> search(
    String query, {
    required SearchMode mode,
    required Set<int> books,
    int limit = 60,
  }) {
    final key = normalize(query);
    if (key.isEmpty) return const [];

    final (String where, List<Object?> args) = switch (mode) {
      SearchMode.starts => ('f >= ? AND f < ?', [key, rangeEnd(key)]),
      SearchMode.ends => () {
        final r = reverseKey(key);
        return ('fr >= ? AND fr < ?', <Object?>[r, rangeEnd(r)]);
      }(),
      SearchMode.contains => ('f LIKE ?', <Object?>['%$key%']),
      SearchMode.exact => ('f = ?', <Object?>[key]),
      SearchMode.root => (
        'f IN (SELECT DISTINCT k FROM entries WHERE rid IN '
            '(SELECT id FROM roots WHERE r = ?))',
        <Object?>[key],
      ),
    };

    // Two steps rather than one join: pick the forms off their index first,
    // then describe only those. Aggregating over every entry a broad prefix
    // touches before applying the limit would be far more work.
    final forms = _db.select(
      'SELECT id, f FROM forms WHERE $where '
      'ORDER BY (f = ?) DESC, LENGTH(f), f LIMIT ?',
      [...args, key, limit],
    );
    if (forms.isEmpty) return const [];

    return _describe([
      for (final row in forms) (row['id'] as int, row['f'] as String),
    ], books);
  }

  /// Fills in the vocalised spelling, sense count and books for each form.
  ///
  /// A form's own headword supplies the spelling when it has one, so a search
  /// for `مهاب` reads `مُهَابٌ` rather than `هَيْبَة` — one of the five
  /// headwords that form also reaches. A form with no headword of its own,
  /// like the plural `مهابل`, keeps its bare spelling and names where it
  /// leads instead.
  List<Headword> _describe(List<(int, String)> forms, Set<int> books) {
    if (forms.isEmpty) return const [];
    final ids = [for (final form in forms) form.$1].join(',');
    final filter = _bookFilter(books).replaceAll(' AND b IN', ' AND e.b IN');

    // `MAX(LENGTH(e.w))` makes SQLite pick the bare `e.w` from the longest —
    // that is, the most fully vocalised — spelling in each group.
    final totals = {
      for (final row in _db.select('''
        SELECT l.fid AS fid, e.w AS w, MAX(LENGTH(e.w)) AS _pick,
               COUNT(*) AS n, GROUP_CONCAT(DISTINCT e.b) AS bs
        FROM links l
        JOIN entries e ON e.k = l.hk
        WHERE l.fid IN ($ids)$filter
        GROUP BY l.fid
      '''))
        row['fid'] as int: row,
    };

    final own = {
      for (final row in _db.select('''
        SELECT l.fid AS fid, e.w AS w, MAX(LENGTH(e.w)) AS _pick
        FROM links l
        JOIN forms f ON f.id = l.fid
        JOIN entries e ON e.k = l.hk
        WHERE l.fid IN ($ids) AND e.k = f.f$filter
        GROUP BY l.fid
      '''))
        row['fid'] as int: row['w'] as String,
    };

    final out = <Headword>[];
    for (final (id, form) in forms) {
      final row = totals[id];
      if (row == null) continue; // every entry filtered out by the book filter
      final headword = own[id];
      final reached = row['w'] as String;
      out.add(
        Headword(
          key: form,
          word: headword ?? form,
          resolvesTo: headword == null ? reached : null,
          senseCount: row['n'] as int,
          bookIds: (row['bs'] as String).split(',').map(int.parse).toList(),
        ),
      );
    }
    return out;
  }

  /// Headwords sharing [rootId], used for the derivations list on an entry.
  List<Headword> byRootId(int rootId, {String? excludeKey, int limit = 80}) {
    final rows = _db.select(
      '''
      SELECT id, f FROM forms
      WHERE f IN (SELECT DISTINCT k FROM entries WHERE rid = ?) AND f <> ?
      ORDER BY LENGTH(f), f
      LIMIT ?
    ''',
      [rootId, excludeKey ?? '', limit],
    );
    return _describe([
      for (final row in rows) (row['id'] as int, row['f'] as String),
    ], const {});
  }

  /// Spelling neighbours plus rhymes — the "كلمات مشابهة" strip.
  List<Headword> similarTo(String key, {int limit = 24}) {
    if (key.length < 2) return const [];
    final stem = key.substring(0, key.length > 3 ? 3 : key.length - 1);
    final rhyme = reverseKey(key.substring(key.length - 2));
    final rows = _db.select(
      '''
      SELECT id, f FROM forms
      WHERE ((f >= ? AND f < ?) OR (fr >= ? AND fr < ?)) AND f <> ?
      ORDER BY ABS(LENGTH(f) - ?), LENGTH(f), f
      LIMIT ?
    ''',
      [stem, rangeEnd(stem), rhyme, rangeEnd(rhyme), key, key.length, limit],
    );
    return _describe([
      for (final row in rows) (row['id'] as int, row['f'] as String),
    ], const {});
  }

  /// Roots that start with [query] — powers the root browser.
  List<({int id, String root, int count})> roots(
    String query, {
    int limit = 200,
  }) {
    final key = normalize(query);
    final rows = key.isEmpty
        ? _db.select('SELECT id, r FROM roots ORDER BY r LIMIT ?', [limit])
        : _db.select(
            'SELECT id, r FROM roots WHERE r >= ? AND r < ? ORDER BY r LIMIT ?',
            [key, rangeEnd(key), limit],
          );
    return rows
        .map((r) => (id: r['id'] as int, root: r['r'] as String, count: 0))
        .toList(growable: false);
  }

  // ------------------------------------------------------------------- entry

  /// Everything the entry page shows for one lookup form.
  ///
  /// A form can explain more than one headword — `مهاب` reaches أهاب، مهاب،
  /// مهب، هاب and هيبة — so the page gathers the senses of all of them, with
  /// the form's own headword first when it is one.
  EntryDetail? entry(String key, {Set<int> books = const {}}) {
    final filter = _bookFilter(books).replaceAll(' AND b IN', ' AND e.b IN');
    final rows = _db.select(
      '''
      SELECT e.id, e.w, e.b, e.rid, e.k, r.r AS root
      FROM forms f
      JOIN links l ON l.fid = f.id
      JOIN entries e ON e.k = l.hk
      LEFT JOIN roots r ON r.id = e.rid
      WHERE f.f = ?$filter
      ORDER BY (e.k = ?) DESC, e.b, e.id
    ''',
      [key, key],
    );
    if (rows.isEmpty) return null;

    final senses = <Sense>[];
    final headKeys = <String>{};
    String? root;
    int? rootId;
    var display = rows.first['w'] as String;
    var displayFromForm = (rows.first['k'] as String) == key;

    for (final row in rows) {
      final id = row['id'] as int;
      final word = row['w'] as String;
      final headKey = row['k'] as String;
      headKeys.add(headKey);

      // Prefer the most vocalised spelling of the form's own headword; fall
      // back to the most vocalised spelling of anything it reaches.
      final fromForm = headKey == key;
      if ((fromForm && !displayFromForm) ||
          (fromForm == displayFromForm && word.length > display.length)) {
        display = word;
        displayFromForm = fromForm;
      }
      if (fromForm || root == null) {
        root ??= row['root'] as String?;
        rootId ??= row['rid'] as int?;
      }
      senses.add(
        Sense(
          id: id,
          word: word,
          bookId: row['b'] as int,
          root: row['root'] as String?,
          lines: _splitSenses(definitionOf(id)),
        ),
      );
    }

    return EntryDetail(
      key: key,
      word: display,
      root: root,
      rootId: rootId,
      senses: senses,
      alsoExplains: headKeys.length > 1 ? headKeys.toList() : const [],
      sameRoot: rootId == null ? const [] : byRootId(rootId, excludeKey: key),
      similar: similarTo(key),
    );
  }

  /// Inflates the block holding [entryId] and returns that entry's definition.
  String definitionOf(int entryId) {
    final chunkId = entryId ~/ _chunkSize;
    final slot = entryId % _chunkSize;
    final chunk = _chunk(chunkId);
    return slot < chunk.length ? chunk[slot] : '';
  }

  List<String> _chunk(int id) {
    final hit = _chunkCache.remove(id);
    if (hit != null) {
      _chunkCache[id] = hit; // refresh recency
      return hit;
    }
    final row = _db.select('SELECT z FROM chunks WHERE id = ?', [id]);
    if (row.isEmpty) return const [];
    final parts = inflateChunk(row.first['z'] as Uint8List);
    _chunkCache[id] = parts;
    if (_chunkCache.length > _maxCachedChunks) {
      _chunkCache.remove(_chunkCache.keys.first);
    }
    return parts;
  }

  /// A single entry chosen by [seed], with the opening line of its
  /// definition — what the dashboard shows as the word of the day.
  ///
  /// Picking by row id rather than `ORDER BY RANDOM()` keeps this an O(1)
  /// primary-key lookup instead of a full scan.
  /// How many oddities the build found. Zero on a database built before the
  /// curiosities table existed, which sends every caller back to [featured].
  late final int curiosityCount = () {
    try {
      final rows = _db.select('SELECT COUNT(*) AS c FROM curios');
      return rows.isEmpty ? 0 : rows.first['c'] as int;
    } catch (_) {
      return 0;
    }
  }();

  /// The word of the day for [day]: the same word for everyone, everywhere.
  ///
  /// Drawn from the corpus's oddities rather than from all 219,764 entries,
  /// because a dictionary should surprise you — and drawn by *permutation*
  /// rather than at random, so that every one of them comes up exactly once
  /// before any of them comes up twice. With tens of thousands of them that
  /// is a cycle measured in centuries.
  Featured? wordOfDay(DateTime day) {
    final total = curiosityCount;
    if (total == 0) {
      // No curiosities: fall back to the old uniform pick over everything.
      return featured(_dayOrdinal(day) * 7919);
    }
    // Walk a few steps in case the chosen entry has no definition recorded.
    for (var step = 0; step < 6; step++) {
      final word = curiosityAt(_dayOrdinal(day) + step);
      if (word != null && word.preview.trim().isNotEmpty) return word;
    }
    return curiosityAt(_dayOrdinal(day));
  }

  /// A run of oddities either side of [day]'s word, for the treasures strip.
  ///
  /// They come from the same permutation, so the strip is never the same two
  /// days running and never repeats a word the reader has just been shown.
  List<Featured> curiositiesFor(DateTime day, {int count = 8}) {
    if (curiosityCount == 0) return const [];
    final ordinal = _dayOrdinal(day);
    final found = <Featured>[];
    for (var step = 1; found.length < count && step < count * 4; step++) {
      final word = curiosityAt(ordinal + step);
      if (word == null || word.preview.trim().isEmpty) continue;
      if (found.any((f) => f.key == word.key)) continue;
      found.add(word);
    }
    return found;
  }

  /// The [step]th word of the permutation over the curiosities.
  Featured? curiosityAt(int step) {
    final total = curiosityCount;
    if (total == 0) return null;
    // A stride coprime with the count makes n -> (n * stride) % total a
    // permutation: every row is visited before any is visited twice.
    final n = ((step.abs() % total) * _stride(total)) % total + 1;
    final rows = _db.select(
      '''
      SELECT e.id, e.k, e.w, e.b, r.r AS root
      FROM curios c
      JOIN entries e ON e.id = c.id
      LEFT JOIN roots r ON r.id = e.rid
      WHERE c.n = ?
    ''',
      [n],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final lines = _splitSenses(definitionOf(row['id'] as int));
    return Featured(
      key: row['k'] as String,
      word: row['w'] as String,
      root: row['root'] as String?,
      bookId: row['b'] as int,
      preview: lines.isEmpty ? '' : lines.first,
    );
  }

  /// Days since 1970 — the same number everywhere on earth for a given date.
  static int _dayOrdinal(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// The first prime at or above 104,729 that shares no factor with [total].
  static int _stride(int total) {
    var stride = 104729;
    while (_gcd(stride, total) != 1) {
      stride++;
    }
    return stride;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  Featured? featured(int seed) {
    final total = entryCount;
    if (total == 0) return null;
    final id = seed.abs() % total;
    final rows = _db.select(
      '''
      SELECT e.id, e.k, e.w, e.b, r.r AS root
      FROM entries e LEFT JOIN roots r ON r.id = e.rid
      WHERE e.id = ?
    ''',
      [id],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final lines = _splitSenses(definitionOf(row['id'] as int));
    return Featured(
      key: row['k'] as String,
      word: row['w'] as String,
      root: row['root'] as String?,
      bookId: row['b'] as int,
      preview: lines.isEmpty ? '' : lines.first,
    );
  }

  // ----------------------------------------------------------- deep search

  /// Sweeps every definition looking for [query].
  ///
  /// This is the one operation that has to touch all 51 MB of text, so it runs
  /// in its own isolate over its own read-only handle and streams progress.
  Stream<DeepSearchEvent> deepSearch(
    String query, {
    required Set<int> bookIds,
    int limit = 200,
  }) {
    final controller = StreamController<DeepSearchEvent>();
    final receive = ReceivePort();
    Isolate? isolate;

    controller.onCancel = () {
      isolate?.kill(priority: Isolate.immediate);
      receive.close();
    };

    receive.listen((dynamic message) {
      if (message is DeepSearchEvent) {
        controller.add(message);
        if (message.done && !controller.isClosed) controller.close();
      } else if (message is List) {
        controller.addError(message.first as Object);
        controller.close();
      }
    });

    Isolate.spawn(
      _deepSearchWorker,
      _DeepJob(
        receive.sendPort,
        path,
        query,
        bookIds.toList(),
        limit,
        _chunkSize,
      ),
      debugName: 'qamus-deep-search',
    ).then((value) => isolate = value);

    return controller.stream;
  }
}

/// The dashboard's word of the day.
@immutable
class Featured {
  const Featured({
    required this.key,
    required this.word,
    required this.bookId,
    required this.preview,
    this.root,
  });

  final String key;
  final String word;
  final String? root;
  final int bookId;
  final String preview;
}

@immutable
class DeepSearchEvent {
  const DeepSearchEvent({
    required this.hits,
    required this.fraction,
    required this.done,
  });

  final List<DeepHit> hits;
  final double fraction;
  final bool done;
}

class _DeepJob {
  const _DeepJob(
    this.send,
    this.path,
    this.query,
    this.bookIds,
    this.limit,
    this.chunkSize,
  );

  final SendPort send;
  final String path;
  final String query;
  final List<int> bookIds;
  final int limit;
  final int chunkSize;
}

void _deepSearchWorker(_DeepJob job) {
  final db = sqlite3.open(job.path, mode: OpenMode.readOnly);
  try {
    final needle = stripMarks(job.query).trim();
    if (needle.isEmpty) {
      job.send.send(const DeepSearchEvent(hits: [], fraction: 1, done: true));
      return;
    }

    final chunkCount =
        (db.select('SELECT MAX(id) AS m FROM chunks').first['m'] as int? ??
            -1) +
        1;
    final allowed = job.bookIds.toSet();
    final hits = <DeepHit>[];
    var batch = <DeepHit>[];

    for (var c = 0; c < chunkCount; c++) {
      final row = db.select('SELECT z FROM chunks WHERE id = ?', [c]);
      if (row.isEmpty) continue;
      final texts = inflateChunk(row.first['z'] as Uint8List);

      for (var slot = 0; slot < texts.length; slot++) {
        final text = texts[slot];
        if (text.isEmpty) continue;
        final at = stripMarks(text).indexOf(needle);
        if (at < 0) continue;

        final id = c * job.chunkSize + slot;
        final meta = db.select('SELECT k, w, b FROM entries WHERE id = ?', [
          id,
        ]);
        if (meta.isEmpty) continue;
        final bookId = meta.first['b'] as int;
        if (allowed.isNotEmpty && !allowed.contains(bookId)) continue;

        batch.add(
          DeepHit(
            key: meta.first['k'] as String,
            word: meta.first['w'] as String,
            bookId: bookId,
            excerpt: _excerpt(text, needle),
          ),
        );
        hits.add(batch.last);
        if (hits.length >= job.limit) break;
      }

      if (batch.isNotEmpty || c % 16 == 0) {
        job.send.send(
          DeepSearchEvent(
            hits: batch,
            fraction: (c + 1) / chunkCount,
            done: false,
          ),
        );
        batch = <DeepHit>[];
      }
      if (hits.length >= job.limit) break;
    }

    job.send.send(DeepSearchEvent(hits: batch, fraction: 1, done: true));
  } catch (error) {
    job.send.send([error.toString()]);
  } finally {
    db.dispose();
  }
}

/// A definition with its diacritics removed, plus a map from each position in
/// the stripped text back to its position in the original.
///
/// Matching happens on the stripped form, but the excerpt has to be cut out of
/// the original — without this map the two index spaces drift apart and the
/// window lands in the wrong place.
({String flat, List<int> map}) flattenWithMap(String text) {
  final buffer = StringBuffer();
  final map = <int>[];
  final chars = text.split('');
  for (var i = 0; i < chars.length; i++) {
    if (stripMarks(chars[i]).isNotEmpty) {
      buffer.write(chars[i]);
      map.add(i);
    }
  }
  return (flat: buffer.toString(), map: map);
}

String _excerpt(String text, String needle) {
  final full = text.replaceAll('|', ' • ');
  final flattened = flattenWithMap(full);
  final at = flattened.flat.indexOf(needle);
  if (at < 0) {
    return full.length <= 180 ? full : '${full.substring(0, 180)}…';
  }

  final flatStart = (at - 45).clamp(0, flattened.flat.length);
  final flatEnd = (at + needle.length + 95).clamp(0, flattened.flat.length);
  final start = flatStart < flattened.map.length ? flattened.map[flatStart] : 0;
  final end = flatEnd < flattened.map.length
      ? flattened.map[flatEnd]
      : full.length;

  final slice = full.substring(start, end);
  return '${start > 0 ? '…' : ''}$slice${end < full.length ? '…' : ''}';
}

/// Inflates one solid definition block into its constituent entries.
///
/// Blocks are `\0`-joined UTF-8, which never collides with the text itself.
List<String> inflateChunk(Uint8List compressed) {
  final raw = zlib.decode(compressed);
  final out = <String>[];
  var start = 0;
  for (var i = 0; i < raw.length; i++) {
    if (raw[i] == 0) {
      out.add(utf8.decode(raw.sublist(start, i), allowMalformed: true));
      start = i + 1;
    }
  }
  out.add(utf8.decode(raw.sublist(start), allowMalformed: true));
  return out;
}

/// Splits a definition on the source's `|` sense separator.
List<String> _splitSenses(String definition) => definition
    .split('|')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList(growable: false);
