import 'package:flutter/foundation.dart';

/// One of the six source dictionaries bundled in the database.
@immutable
class Book {
  const Book({
    required this.id,
    required this.name,
    required this.dict,
    required this.count,
  });

  final int id;
  final String name;

  /// `معاني` (definitions) or `مرادفات` (synonyms & antonyms).
  final String dict;
  final int count;

  bool get isThesaurus => dict == 'مرادفات';
}

/// A search hit: one headword, collapsed across every vocalisation and book.
@immutable
class Headword {
  const Headword({
    required this.key,
    required this.word,
    required this.senseCount,
    required this.bookIds,
    this.resolvesTo,
    this.root,
  });

  /// Normalised key — the identity of the headword.
  final String key;

  /// Best (most fully vocalised) spelling to show.
  final String word;

  /// When this form is not a headword of its own — `مهابل` is a plural whose
  /// singular `مهبل` carries the definition — the headword it leads to.
  final String? resolvesTo;
  final int senseCount;
  final List<int> bookIds;
  final String? root;
}

/// A single row of the source dictionary, expanded for display.
@immutable
class Sense {
  const Sense({
    required this.id,
    required this.word,
    required this.bookId,
    required this.lines,
    this.root,
  });

  final int id;
  final String word;
  final int bookId;
  final String? root;

  /// The definition split on the source's `|` sense separator.
  final List<String> lines;
}

/// Everything shown on the entry page.
@immutable
class EntryDetail {
  const EntryDetail({
    required this.key,
    required this.word,
    required this.senses,
    required this.sameRoot,
    required this.similar,
    this.alsoExplains = const [],
    this.root,
    this.rootId,
  });

  final String key;
  final String word;
  final String? root;
  final int? rootId;
  final List<Sense> senses;

  /// The headword keys this form resolves to, when it reaches more than one.
  /// `مهاب` reaches أهاب، مهاب، مهب، هاب and هيبة.
  final List<String> alsoExplains;

  /// Other headwords derived from the same triliteral root.
  final List<Headword> sameRoot;

  /// Neighbours by spelling and by rhyme.
  final List<Headword> similar;
}

/// How the query string is matched against the index.
enum SearchMode {
  starts('يبدأ بـ', 'ابتداء'),
  ends('ينتهي بـ', 'انتهاء'),
  contains('يحتوي على', 'احتواء'),
  exact('مطابق تمامًا', 'مطابقة'),
  root('الجذر', 'جذر');

  const SearchMode(this.label, this.short);
  final String label;
  final String short;
}

/// A hit from the full-text sweep through the compressed definitions.
@immutable
class DeepHit {
  const DeepHit({
    required this.key,
    required this.word,
    required this.bookId,
    required this.excerpt,
  });

  final String key;
  final String word;
  final int bookId;
  final String excerpt;
}
