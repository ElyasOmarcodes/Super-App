import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/locales.dart';
import 'models.dart';

/// User preferences, search history and favourites.
///
/// Everything lives in `SharedPreferences`; the dictionary file itself is
/// never written to, so a corrupt preference can never damage the corpus.
class Settings extends ChangeNotifier {
  Settings._(this._prefs, this._allBookIds);

  final SharedPreferences _prefs;
  final Set<int> _allBookIds;

  static const _kBooks = 'books';
  static const _kTheme = 'themeMode';
  static const _kScale = 'textScale';
  static const _kMode = 'searchMode';
  static const _kHistory = 'history';
  static const _kFavourites = 'favourites';
  static const _kVowels = 'showVowels';
  static const _kLocale = 'locale';
  static const _kOnboarded = 'onboarded';
  static const _kNotify = 'dailyWord';
  static const _kNotifyHour = 'dailyWordHour';

  static Future<Settings> load(Iterable<int> allBookIds) async {
    final prefs = await SharedPreferences.getInstance();
    return Settings._(prefs, allBookIds.toSet());
  }

  // ------------------------------------------------------------------ books
  /// The books a search is restricted to. Empty means "all of them".
  Set<int> get selectedBooks {
    final raw = _prefs.getStringList(_kBooks);
    if (raw == null) return {..._allBookIds};
    final ids = raw
        .map(int.tryParse)
        .whereType<int>()
        .where(_allBookIds.contains)
        .toSet();
    return ids.isEmpty ? {..._allBookIds} : ids;
  }

  bool get allBooksSelected => selectedBooks.length == _allBookIds.length;

  bool isBookSelected(int id) => selectedBooks.contains(id);

  Future<void> toggleBook(int id) async {
    final next = selectedBooks;
    if (next.contains(id)) {
      if (next.length == 1) return; // never leave the reader with nothing
      next.remove(id);
    } else {
      next.add(id);
    }
    await _prefs.setStringList(_kBooks, next.map((e) => '$e').toList());
    notifyListeners();
  }

  Future<void> setBooks(Set<int> ids) async {
    final next = ids.isEmpty ? {..._allBookIds} : ids;
    await _prefs.setStringList(_kBooks, next.map((e) => '$e').toList());
    notifyListeners();
  }

  Future<void> selectAllBooks() => setBooks({..._allBookIds});

  // --------------------------------------------------------------- locale
  /// Null until the reader picks a language on first launch, which is what
  /// makes the language screen appear exactly once.
  AppLocale? get chosenLocale {
    final code = _prefs.getString(_kLocale);
    return code == null ? null : AppLocale.fromCode(code);
  }

  AppLocale get appLocale => chosenLocale ?? AppLocale.ar;

  Future<void> setLocale(AppLocale locale) async {
    await _prefs.setString(_kLocale, locale.code);
    notifyListeners();
  }

  /// False until the intro pages have been seen through.
  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;

  // ---------------------------------------------------------- notifications
  /// Whether the reader wants the word of the day delivered.
  ///
  /// This is the reader's *wish*, kept separately from whether the system has
  /// actually granted permission — someone can turn the switch on before the
  /// platform dialog, or revoke the grant in system settings afterwards.
  bool get dailyWord => _prefs.getBool(_kNotify) ?? false;

  Future<void> setDailyWord(bool value) async {
    await _prefs.setBool(_kNotify, value);
    notifyListeners();
  }

  /// The hour of the day, 0–23, the word arrives at. Morning by default.
  int get dailyWordHour => _prefs.getInt(_kNotifyHour) ?? 8;

  Future<void> setDailyWordHour(int hour) async {
    await _prefs.setInt(_kNotifyHour, hour.clamp(0, 23));
    notifyListeners();
  }

  Future<void> setOnboarded(bool value) async {
    await _prefs.setBool(_kOnboarded, value);
    notifyListeners();
  }

  // ---------------------------------------------------------------- display
  ThemeMode get themeMode =>
      ThemeMode.values[_prefs.getInt(_kTheme) ?? ThemeMode.system.index];

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_kTheme, mode.index);
    notifyListeners();
  }

  double get textScale => _prefs.getDouble(_kScale) ?? 1.0;

  Future<void> setTextScale(double value) async {
    await _prefs.setDouble(_kScale, value.clamp(0.8, 1.8));
    notifyListeners();
  }

  bool get showVowels => _prefs.getBool(_kVowels) ?? true;

  Future<void> setShowVowels(bool value) async {
    await _prefs.setBool(_kVowels, value);
    notifyListeners();
  }

  // ----------------------------------------------------------------- search
  SearchMode get searchMode =>
      SearchMode.values[_prefs.getInt(_kMode) ?? SearchMode.starts.index];

  Future<void> setSearchMode(SearchMode mode) async {
    await _prefs.setInt(_kMode, mode.index);
    notifyListeners();
  }

  // ---------------------------------------------------------------- history
  List<String> get history => _prefs.getStringList(_kHistory) ?? const [];

  Future<void> remember(String key, String word) async {
    if (key.isEmpty) return;
    final list = [...history]..removeWhere((e) => decode(e).key == key);
    list.insert(0, '$key $word');
    await _prefs.setStringList(_kHistory, list.take(60).toList());
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_kHistory);
    notifyListeners();
  }

  // ------------------------------------------------------------- favourites
  List<String> get favourites => _prefs.getStringList(_kFavourites) ?? const [];

  bool isFavourite(String key) => favourites.any((e) => decode(e).key == key);

  Future<void> toggleFavourite(String key, String word) async {
    final list = [...favourites];
    final at = list.indexWhere((e) => decode(e).key == key);
    if (at >= 0) {
      list.removeAt(at);
    } else {
      list.insert(0, '$key $word');
    }
    await _prefs.setStringList(_kFavourites, list);
    notifyListeners();
  }

  /// Decodes a space-separated `key word` record.
  static ({String key, String word}) decode(String record) {
    final at = record.indexOf(' ');
    if (at < 0) return (key: record, word: record);
    return (key: record.substring(0, at), word: record.substring(at + 1));
  }
}
