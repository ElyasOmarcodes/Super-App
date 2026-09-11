import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/data/arabic.dart';

void main() {
  group('normalize', () {
    test('strips harakat', () {
      expect(normalize('اِقتَدَحَ'), 'اقتدح');
      expect(normalize('الْعِلْمُ'), 'العلم');
    });

    test('folds hamza seats and alef variants', () {
      expect(normalize('أَخَذَ'), normalize('اخذ'));
      expect(normalize('إبراهيم'), normalize('ابراهيم'));
      expect(normalize('آمَنَ'), normalize('امن'));
      expect(normalize('مُؤْمِن'), normalize('مومن'));
      expect(normalize('ذِئْب'), normalize('ذيب'));
    });

    test('folds alef maqsura and ta marbuta', () {
      expect(normalize('ابتَغَى'), normalize('ابتغي'));
      expect(normalize('استحارَة'), normalize('استحاره'));
    });

    test('drops the standalone hamza so شيء matches شي', () {
      expect(normalize('شَيْء'), 'شي');
    });

    test('drops spaces, punctuation, digits and tatweel', () {
      expect(normalize('أَخَذَ مِن'), 'اخذمن');
      expect(normalize('كتـــاب'), 'كتاب');
      expect(normalize('باب (3)'), 'باب');
    });

    test('returns an empty key for non-Arabic input', () {
      expect(normalize('hello 123'), '');
      expect(normalize(''), '');
    });
  });

  group('reverseKey', () {
    test('reverses the key so a prefix scan becomes a suffix search', () {
      expect(reverseKey('كتاب'), 'باتك');
      expect(reverseKey(reverseKey('مكتبة')), 'مكتبة');
    });

    test('a suffix query is the prefix of the reversed key', () {
      final word = reverseKey(normalize('غَرِيب'));
      final query = reverseKey(normalize('يب'));
      expect(word.startsWith(query), isTrue);
    });

    test('the same suffix matches across hamza variants', () {
      final query = reverseKey(normalize('يب'));
      for (final word in ['ذِئْب', 'طَيِّب', 'غَرِيب']) {
        expect(
          reverseKey(normalize(word)).startsWith(query),
          isTrue,
          reason: word,
        );
      }
    });
  });

  group('rangeEnd', () {
    test('bounds a prefix scan above every continuation', () {
      final start = normalize('كتب');
      final end = rangeEnd(start);
      expect(start.compareTo(end) < 0, isTrue);
      final longer = '$start\u0629';
      expect(longer.compareTo(end) < 0, isTrue);
      expect(normalize('كتج').compareTo(end) > 0, isTrue);
    });
  });

  test('stripMarks keeps letters but removes vowel marks', () {
    expect(stripMarks('الْعِلْمُ نُورٌ'), 'العلم نور');
  });
}
