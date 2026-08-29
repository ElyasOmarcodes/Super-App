@Timeout(Duration(minutes: 6))
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/data/arabic.dart';
import 'package:qamus/src/data/corpus.dart';
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
    final asset = File('assets/db/qamus.corpus.xz');
    expect(
      asset.existsSync(),
      isTrue,
      reason: 'the packed corpus must ship with the app',
    );

    final target = '${workspace.path}/qamus.db';
    buildDatabase(
      Uint8List.fromList(XZDecoder().decodeBytes(asset.readAsBytesSync())),
      target,
      (_, _) {},
    );
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

  group('the lookup form index', () {
    test('finds inflected forms that are not headwords themselves', () {
      // مهابل is a plural; the corpus has no such headword, only مهبل. The
      // source's Keys table records the link, and without it this search
      // returns nothing at all.
      final hits = dictionary.search(
        'مهابل',
        mode: SearchMode.exact,
        books: allBooks,
      );
      expect(hits, isNotEmpty, reason: 'مهابل must resolve to مهبل');

      final entry = dictionary.entry('مهابل');
      expect(entry, isNotNull);
      expect(entry!.senses, isNotEmpty);
    });

    test('the prefix مهاب offers every form the source knows', () {
      final hits = dictionary.search(
        'مهاب',
        mode: SearchMode.starts,
        books: allBooks,
        limit: 60,
      );
      final keys = hits.map((h) => h.key).toSet();
      for (final form in [
        'مهاب',
        'مهابه',
        'مهابط',
        'مهابل',
        'مهابيب',
        'مهابيج',
        'مهابيل',
      ]) {
        expect(keys, contains(form), reason: form);
      }
    });

    test('one form gathers the senses of every headword it explains', () {
      final entry = dictionary.entry('مهاب');
      expect(entry, isNotNull);
      // مهاب reaches أهاب، مهاب، مهب، هاب and هيبة, so its page carries far
      // more than the three senses of the headword مهاب alone.
      expect(entry!.alsoExplains.length, greaterThan(1));
      expect(entry.senses.length, greaterThan(10));
      expect(
        entry.senses.map((s) => s.bookId).toSet().length,
        greaterThan(2),
        reason: 'senses should span several lexicons',
      );
    });

    test('the definite article is transparent both ways', () {
      final withArticle = dictionary.entry('الرحيم');
      final without = dictionary.entry('رحيم');
      expect(withArticle, isNotNull);
      expect(without, isNotNull);

      // Searching either spelling reaches both headwords, and the results
      // still show the الـ form rather than silently dropping it.
      expect(withArticle!.alsoExplains, contains('الرحيم'));
      expect(withArticle.alsoExplains, contains('رحيم'));
      expect(without!.alsoExplains, contains('الرحيم'));

      final hits = dictionary.search(
        'الرحيم',
        mode: SearchMode.exact,
        books: allBooks,
      );
      expect(hits, isNotEmpty);
      expect(hits.first.key, 'الرحيم');
    });

    test('a result shows its own headword, not one it merely reaches', () {
      final hits = dictionary.search(
        'مهاب',
        mode: SearchMode.exact,
        books: allBooks,
      );
      expect(hits, isNotEmpty);
      final head = hits.first;
      // مهاب reaches هيبة among others; the row must still read مهاب.
      expect(normalize(head.word), 'مهاب');
      expect(head.resolvesTo, isNull);

      final plural = dictionary
          .search('مهابل', mode: SearchMode.exact, books: allBooks)
          .first;
      // مهابل has no headword of its own, so it keeps its bare spelling and
      // names the singular that carries the definition.
      expect(plural.key, 'مهابل');
      expect(plural.resolvesTo, isNotNull);
      expect(normalize(plural.resolvesTo!), 'مهبل');
    });

    test('every headword remains reachable as a form', () {
      for (final word in ['كتب', 'مهاب', 'غريب', 'سلسبيل', 'شعفه']) {
        expect(
          dictionary.search(word, mode: SearchMode.exact, books: allBooks),
          isNotEmpty,
          reason: word,
        );
      }
    });
  });

  test('an empty or non-Arabic query never returns results', () {
    for (final mode in SearchMode.values) {
      expect(dictionary.search('', mode: mode, books: allBooks), isEmpty);
      expect(dictionary.search('!!!', mode: mode, books: allBooks), isEmpty);
    }
  });
}
