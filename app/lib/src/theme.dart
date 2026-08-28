import 'package:flutter/material.dart';

/// The visual identity: warm parchment by day, deep ink by night, with a jade
/// accent and gold highlights borrowed from illuminated manuscripts.
class QamusTheme {
  static const seedLight = Color(0xFF0F6E5C);
  static const seedDark = Color(0xFF4FD1B5);

  static const gold = Color(0xFFB98A3C);

  static const String display = 'Amiri';
  static const String ui = 'Tajawal';

  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: seedLight,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFFBF7EF),
      surfaceContainerLowest: const Color(0xFFFFFCF6),
      surfaceContainerLow: const Color(0xFFF7F1E6),
      surfaceContainer: const Color(0xFFF2EBDD),
      surfaceContainerHigh: const Color(0xFFEDE4D3),
      surfaceContainerHighest: const Color(0xFFE7DCC8),
      onSurface: const Color(0xFF221E17),
      onSurfaceVariant: const Color(0xFF5C5445),
      outlineVariant: const Color(0xFFDCD2BF),
      tertiary: gold,
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: seedDark,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF121110),
      surfaceContainerLowest: const Color(0xFF0C0B0A),
      surfaceContainerLow: const Color(0xFF1A1816),
      surfaceContainer: const Color(0xFF1F1D1A),
      surfaceContainerHigh: const Color(0xFF2A2723),
      surfaceContainerHighest: const Color(0xFF35312B),
      onSurface: const Color(0xFFEDE6DA),
      onSurfaceVariant: const Color(0xFFB6AC9B),
      outlineVariant: const Color(0xFF3A352E),
      tertiary: const Color(0xFFE3BC72),
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(base.textTheme, scheme),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: display,
          fontSize: 24,
          height: 1.6,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(
          fontFamily: ui,
          fontSize: 13,
          color: scheme.onSurface,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(fontFamily: display, fontSize: 20),
        subtitleTextStyle: TextStyle(fontFamily: ui, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: TextStyle(
          fontFamily: ui,
          color: scheme.onSurfaceVariant,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: ui,
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) =>
      base.copyWith(
        displayLarge: TextStyle(
          fontFamily: display,
          fontSize: 46,
          height: 1.5,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: display,
          fontSize: 36,
          height: 1.5,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontFamily: display,
          fontSize: 30,
          height: 1.55,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: display,
          fontSize: 26,
          height: 1.55,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: display,
          fontSize: 22,
          height: 1.6,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: ui,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: ui,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: ui,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
        bodyLarge: TextStyle(
          fontFamily: display,
          fontSize: 20,
          height: 1.95,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: ui,
          fontSize: 14,
          height: 1.8,
          color: scheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: ui,
          fontSize: 12,
          height: 1.7,
          color: scheme.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontFamily: ui,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: ui,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(fontFamily: ui, fontSize: 11),
      );
}

/// Colour used to tint a book's chip and section header, so the six sources
/// stay distinguishable at a glance.
Color bookColor(int bookId, ColorScheme scheme) {
  const hues = [168.0, 32.0, 210.0, 288.0, 8.0, 128.0];
  final hue = hues[(bookId - 1) % hues.length];
  final isDark = scheme.brightness == Brightness.dark;
  return HSLColor.fromAHSL(
    1,
    hue,
    isDark ? 0.42 : 0.48,
    isDark ? 0.62 : 0.36,
  ).toColor();
}
