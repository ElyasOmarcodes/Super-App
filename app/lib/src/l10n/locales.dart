import 'package:flutter/material.dart';

/// The four languages the interface speaks.
///
/// Arabic is the default: the corpus itself is Arabic, so it is the language
/// the app is read in unless the reader says otherwise on first launch.
enum AppLocale {
  ar('ar', 'العربية', 'Arabic', TextDirection.rtl, _arabicIndic),
  ps('ps', 'پښتو', 'Pashto', TextDirection.rtl, _easternArabicIndic),
  fa('fa', 'فارسی', 'Persian', TextDirection.rtl, _easternArabicIndic),
  en('en', 'English', 'English', TextDirection.ltr, _western);

  const AppLocale(
    this.code,
    this.nativeName,
    this.englishName,
    this.textDirection,
    this._digitBase,
  );

  final String code;

  /// How the language names itself — the only sensible label on a picker.
  final String nativeName;
  final String englishName;
  final TextDirection textDirection;
  final int _digitBase;

  Locale get locale => Locale(code);

  bool get isRtl => textDirection == TextDirection.rtl;

  static const _arabicIndic = 0x0660; // ٠١٢٣٤٥٦٧٨٩
  static const _easternArabicIndic = 0x06F0; // ۰۱۲۳۴۵۶۷۸۹
  static const _western = 0x0030;

  static AppLocale fromCode(String? code) => AppLocale.values.firstWhere(
    (l) => l.code == code,
    orElse: () => AppLocale.ar,
  );

  /// Matches the platform locale, falling back to Arabic.
  static AppLocale fromPlatform(Locale locale) => AppLocale.values.firstWhere(
    (l) => l.code == locale.languageCode,
    orElse: () => AppLocale.ar,
  );

  /// Renders [value] in this language's digits, with a thousands separator.
  String number(int value) {
    final digits = value.abs().toString();
    final separator = this == AppLocale.en ? ',' : '٬';
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
      buffer.writeCharCode(_digitBase + (digits.codeUnitAt(i) - 0x30));
    }
    return buffer.toString();
  }
}
