/// Number and counted-noun formatting for the Arabic interface.
library;

/// Renders [value] with Arabic-Indic digits and a thousands separator.
String arabicNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '؜-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('٬');
    buffer.write(String.fromCharCode(0x0660 + (digits.codeUnitAt(i) - 0x30)));
  }
  return buffer.toString();
}

/// Arabic counted nouns agree with the number: one takes the singular, two the
/// dual, three to ten the plural, and eleven upward the accusative singular.
///
/// Getting this wrong is immediately jarring to read — "١ معاجم" is the sort
/// of thing that makes an app feel machine-translated.
String counted(
  int n, {
  required String one,
  required String two,
  required String few,
  required String many,
}) {
  if (n == 1) return one;
  if (n == 2) return two;
  if (n >= 3 && n <= 10) return '${arabicNumber(n)} $few';
  return '${arabicNumber(n)} $many';
}

String countedBooks(int n) =>
    counted(n, one: 'معجم واحد', two: 'معجمان', few: 'معاجم', many: 'معجمًا');

String countedSenses(int n) =>
    counted(n, one: 'شرح واحد', two: 'شرحان', few: 'شروح', many: 'شرحًا');

String countedEntries(int n) =>
    counted(n, one: 'مدخل واحد', two: 'مدخلان', few: 'مداخل', many: 'مدخلًا');

String countedResults(int n) => counted(
  n,
  one: 'نتيجة واحدة',
  two: 'نتيجتان',
  few: 'نتائج',
  many: 'نتيجةً',
);

String countedWords(int n) =>
    counted(n, one: 'كلمة واحدة', two: 'كلمتان', few: 'كلمات', many: 'كلمةً');
