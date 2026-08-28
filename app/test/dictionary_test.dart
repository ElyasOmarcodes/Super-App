@Timeout(Duration(minutes: 6))
library;

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/data/arabic.dart';
import 'package:qamus/src/data/bootstrap.dart';
import 'package:qamus/src/data/dictionary.dart';
import 'package:qamus/src/data/models.dart';

/// Exercises the real shipped corpus end to end: unpack the asset, run the
/// on-device preparation, then query it the way the UI does.
void main() {
  late Directory workspace;
  late Dictionary dictionary;
  late Set<int> allBooks;

  setUpAll(() async {
    workspace = Directory.systemTemp.createTempSync('qamus-test');
    final asset = File('assets/db/qamus.db.xz');
    expect(
      asset.existsSync(),
      isTrue,
      reason: 'the packed database must ship with the app',
    );

    final target = '${workspace.path}/qamus.db';
    File(
      target,
    ).writeAsBytesSync(XZDecoder().decodeBytes(asset.readAsBytesSync()));
    prepareDatabase(target, (_, _) {});
    dictionary = await Dictionary.open(target);
    allBooks = dictionary.books.map((b) => b.id).toSet();
  });

  tearDownAll(() {
    dictionary.dispose();
    workspace.deleteSync(recursive: true);
  });

  test('the corpus is complete', () {
    expect(dictionary.entryCount, 219764);
    expect(dictionary.books.length, 6);
    expect(dictionary.rootCount, greaterThan(16000));
    expect(dictionary.books.map((b) => b.name), contains('معجم الوسيط'));
    expect(dictionary.books.fold<int>(0, (sum, b) => sum + b.count), 219764);
  });

  test('prefix search finds a headword and collapses its vocalisations', () {
    final hits = dictionary.search(
      'كتب',
      mode: SearchMode.starts,
      books: allBooks,
    );
    expect(hits, isNotEmpty);
    expect(hits.first.key, 'كتب', reason: 'an exact key must rank first');
    expect(hits.first.senseCount, greaterThan(1));
    expect(
      hits.map((h) => h.key).toSet().length,
      hits.length,
      reason: 'keys must be unique after grouping',
    );
    for (final hit in hits) {
      expect(hit.key.startsWith('كتب'), isTrue);
    }
  });

  test('search is forgiving about hamza seats and harakat', () {
    final vocalised = dictionary.search(
      'أَخَذَ',
      mode: SearchMode.exact,
      books: allBooks,
    );
    final bare = dictionary.search(
      'اخذ',
      mode: SearchMode.exact,
      books: allBooks,
    );
    expect(vocalised, isNotEmpty);
    expect(bare, isNotEmpty);
    expect(vocalised.first.key, bare.first.key);
  });

  test('suffix search returns only words ending in the query', () {
    final hits = dictionary.search(
      'يب',
      mode: SearchMode.ends,
      books: allBooks,
      limit: 200,
    );
    expect(hits.length, greaterThan(50));
    for (final hit in hits) {
      expect(hit.key.endsWith('يب'), isTrue, reason: hit.word);
    }
    expect(hits.map((h) => h.key), contains('غريب'));
  });

  test('contains search matches in the middle of a word', () {
    final hits = dictionary.search(
      'سلسب',
      mode: SearchMode.contains,
      books: allBooks,
    );
    expect(hits, isNotEmpty);
    for (final hit in hits) {
      expect(hit.key.contains('سلسب'), isTrue);
    }
  });

  test('root search gathers a whole derivational family', () {
    final hits = dictionary.search(
      'كتب',
      mode: SearchMode.root,
      books: allBooks,
      limit: 300,
    );
    expect(hits.length, greaterThan(20));
    expect(hits.map((h) => h.key), contains('مكتبه'));
  });

  test('the book filter restricts results to the chosen sources', () {
    final wasit = dictionary.books.firstWhere((b) => b.name == 'معجم الوسيط');
    final filtered = dictionary.search(
      'كتب',
      mode: SearchMode.starts,
      books: {wasit.id},
      limit: 200,
    );
    expect(filtered, isNotEmpty);
    for (final hit in filtered) {
      expect(hit.bookIds, [wasit.id]);
    }
    final all = dictionary.search(
      'كتب',
      mode: SearchMode.starts,
      books: allBooks,
      limit: 200,
    );
    expect(all.length, greaterThan(filtered.length));
  });

  test('an entry carries its definitions, root and neighbours', () {
    final entry = dictionary.entry('كتب');
    expect(entry, isNotNull);
    expect(entry!.root, 'كتب');
    expect(entry.senses, isNotEmpty);
    expect(
      entry.senses.every((s) => s.lines.isNotEmpty),
      isTrue,
      reason: 'every sense must inflate to real text',
    );
    expect(entry.sameRoot, isNotEmpty);
    expect(entry.sameRoot.map((h) => h.key), isNot(contains('كتب')));
    expect(entry.similar, isNotEmpty);
  });

  test('definitions round-trip out of their compressed blocks', () {
    // Sample across the whole id range so several blocks get inflated.
    for (final id in [0, 1, 511, 512, 100000, 219763]) {
      final text = dictionary.definitionOf(id);
      expect(text, isNotEmpty, reason: 'entry $id');
      expect(
        text.codeUnits,
        isNot(contains(0)),
        reason: 'the block separator must never leak into a definition',
      );
    }
  });

  test('the block cache does not corrupt neighbouring entries', () {
    final first = dictionary.definitionOf(1000);
    for (final id in [200000, 50, 130000, 4000, 90000, 170000, 60]) {
      dictionary.definitionOf(id);
    }
    expect(dictionary.definitionOf(1000), first);
  });

  test('deep search finds a phrase inside the definition text', () async {
    final events = await dictionary
        .deepSearch('سلسبيل', bookIds: allBooks, limit: 5)
        .toList();
    final hits = [for (final e in events) ...e.hits];
    expect(hits, isNotEmpty);
    expect(events.last.done, isTrue);
    for (final hit in hits) {
      expect(stripMarks(hit.excerpt), contains('سلسبيل'));
    }
  });

  test('an empty or non-Arabic query never returns results', () {
    for (final mode in SearchMode.values) {
      expect(dictionary.search('', mode: mode, books: allBooks), isEmpty);
      expect(dictionary.search('!!!', mode: mode, books: allBooks), isEmpty);
    }
  });
}
