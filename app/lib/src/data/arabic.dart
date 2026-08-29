/// Arabic text handling shared by the whole app.
///
/// [normalize] is the single source of truth for the search key `k` that is
/// materialised into the database on first launch.  If it ever changes, the
/// stored keys must be rebuilt, which is what [kNormalizerVersion] tracks.
library;

const int kNormalizerVersion = 1;

/// Combining marks that carry no lexical weight for searching:
/// honorifics, harakat, tanween, shadda, sukun, superscript alef, Quranic
/// annotation marks, the Arabic Extended-A block and the tatweel joiner.
final RegExp _marks = RegExp(
  '['
  '\u0610-\u061A' // honorifics
  '\u064B-\u065F' // harakat, tanween, shadda, sukun
  '\u0670' // superscript alef
  '\u06D6-\u06ED' // Quranic annotation marks
  '\u08D3-\u08FF' // Arabic Extended-A marks
  '\u0640' // tatweel
  '\u200B-\u200F' // zero-width joiners and marks
  '\u202A-\u202E' // bidi embedding controls
  '\u2066-\u2069' // bidi isolates
  ']',
);

/// Anything that is not a plain Arabic letter is dropped from the key, so
/// spaces, punctuation, digits and Latin never get in the way of a match.
final RegExp _notLetter = RegExp('[^\u0621-\u064A]');

const Map<String, String> _fold = {
  'أ': 'ا', // أ
  'إ': 'ا', // إ
  'آ': 'ا', // آ
  'ٱ': 'ا', // ٱ
  'ٲ': 'ا',
  'ٳ': 'ا',
  'ٵ': 'ا',
  'ى': 'ي', // ى
  'ئ': 'ي', // ئ
  'ی': 'ي', // ی (Persian yeh)
  'ي': 'ي',
  'ؤ': 'و', // ؤ
  'ة': 'ه', // ة
  'ک': 'ك', // ک (Persian kaf)
  'ء': '', // standalone hamza is dropped: شيء == شي
};

/// Folds a word down to its bare skeleton so that a reader who types without
/// diacritics — and without caring about hamza seats — still finds the entry.
String normalize(String input) {
  if (input.isEmpty) return '';
  final stripped = input.replaceAll(_marks, '');
  final buf = StringBuffer();
  for (final ch in stripped.split('')) {
    final folded = _fold[ch];
    if (folded != null) {
      buf.write(folded);
    } else if (!_notLetter.hasMatch(ch)) {
      buf.write(ch);
    }
  }
  return buf.toString();
}

/// The key stored in `entries.kr`; a prefix scan over it is a suffix search.
String reverseKey(String key) {
  final units = key.split('');
  return units.reversed.join();
}

/// Upper bound for a `k >= prefix AND k < prefixEnd` range scan.
String rangeEnd(String prefix) => '$prefix\u{10FFFF}';

/// Strips diacritics but keeps the word readable — used when echoing a query.
String stripMarks(String input) => input.replaceAll(_marks, '');

/// True when the string contains at least one Arabic letter.
bool hasArabic(String input) => RegExp('[\u0621-\u064A]').hasMatch(input);
