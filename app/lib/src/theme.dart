import 'package:flutter/material.dart';

/// The visual identity: a clean modern surface — near-white by day, near-black
/// by night — with saturated accent colours doing all the talking.
///
/// Nothing is tinted beige. Colour arrives through cards, gradients and icons
/// against a neutral ground, which is what keeps a dense reference app legible
/// while still feeling alive.
class QamusTheme {
  static const String font = 'Vazirmatn';

  /// Corner radius shared by cards, sheets and pills.
  static const double radius = 22;

  // ------------------------------------------------------------- accents
  // Six hues, used for the six lexicons, the dashboard cards and the section
  // headers. They are deliberately equal in weight so no card shouts.
  static const violet = Color(0xFF7C5CFF);
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF06B6D4);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);

  static const accents = [violet, blue, cyan, emerald, amber, rose];

  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: violet,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF7F7FB),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: const Color(0xFFF2F2F7),
      surfaceContainerHigh: const Color(0xFFECECF3),
      surfaceContainerHighest: const Color(0xFFE4E4EE),
      onSurface: const Color(0xFF14141B),
      onSurfaceVariant: const Color(0xFF6B6B7B),
      outlineVariant: const Color(0xFFE6E6EE),
      primary: violet,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEDE9FF),
      onPrimaryContainer: const Color(0xFF34219E),
      tertiary: amber,
      shadow: const Color(0xFF1A1A2E),
    ),
    Brightness.light,
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: violet,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF0B0B12),
      surfaceContainerLowest: const Color(0xFF101018),
      surfaceContainerLow: const Color(0xFF15151F),
      surfaceContainer: const Color(0xFF1A1A25),
      surfaceContainerHigh: const Color(0xFF22222E),
      surfaceContainerHighest: const Color(0xFF2B2B38),
      onSurface: const Color(0xFFECECF2),
      onSurfaceVariant: const Color(0xFF9A9AAC),
      outlineVariant: const Color(0xFF272733),
      primary: const Color(0xFF9E8BFF),
      onPrimary: const Color(0xFF1A0F4D),
      primaryContainer: const Color(0xFF2C2350),
      onPrimaryContainer: const Color(0xFFDDD5FF),
      tertiary: amber,
      shadow: Colors.black,
    ),
    Brightness.dark,
  );

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(base.textTheme, scheme),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SoftPageTransition(),
          TargetPlatform.iOS: _SoftPageTransition(),
          TargetPlatform.windows: _SoftPageTransition(),
          TargetPlatform.linux: _SoftPageTransition(),
          TargetPlatform.macOS: _SoftPageTransition(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 20,
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
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(
          fontFamily: font,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primary,
        secondarySelectedColor: scheme.primary,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(fontFamily: font, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: TextStyle(
          fontFamily: font,
          color: scheme.onSurfaceVariant,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: font,
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        width: 320,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) =>
      base.copyWith(
        displayLarge: _s(40, FontWeight.w700, 1.3, scheme.onSurface),
        displayMedium: _s(32, FontWeight.w700, 1.35, scheme.onSurface),
        headlineLarge: _s(27, FontWeight.w700, 1.4, scheme.onSurface),
        headlineMedium: _s(23, FontWeight.w700, 1.45, scheme.onSurface),
        headlineSmall: _s(20, FontWeight.w600, 1.55, scheme.onSurface),
        titleLarge: _s(17, FontWeight.w700, 1.5, scheme.onSurface),
        titleMedium: _s(15, FontWeight.w600, 1.5, scheme.onSurface),
        titleSmall: _s(13, FontWeight.w500, 1.5, scheme.onSurfaceVariant),
        // Definition text: generous leading, because vocalised Arabic stacks
        // marks above and below the line.
        bodyLarge: _s(18, FontWeight.w400, 2.0, scheme.onSurface),
        bodyMedium: _s(14, FontWeight.w400, 1.8, scheme.onSurface),
        bodySmall: _s(12, FontWeight.w400, 1.7, scheme.onSurfaceVariant),
        labelLarge: _s(14, FontWeight.w600, 1.4, scheme.onSurface),
        labelMedium: _s(12, FontWeight.w500, 1.4, scheme.onSurfaceVariant),
        labelSmall: _s(11, FontWeight.w400, 1.5, scheme.onSurfaceVariant),
      );

  static TextStyle _s(
    double size,
    FontWeight weight,
    double height,
    Color color,
  ) => TextStyle(
    fontFamily: font,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// The soft drop shadow every raised card wears.
  static List<BoxShadow> shadow(ColorScheme scheme, {double strength = 1}) => [
    BoxShadow(
      color: scheme.shadow.withValues(
        alpha: (scheme.brightness == Brightness.dark ? 0.5 : 0.07) * strength,
      ),
      blurRadius: 24 * strength,
      offset: Offset(0, 8 * strength),
    ),
  ];

  /// A two-stop wash of one accent, used for the dashboard's colour cards.
  static LinearGradient gradient(Color accent, {double opacity = 1}) =>
      LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          Color.lerp(accent, Colors.white, 0.12)!.withValues(alpha: opacity),
          Color.lerp(
            accent,
            const Color(0xFF120C2E),
            0.26,
          )!.withValues(alpha: opacity),
        ],
      );
}

/// Colour used to tint a book's chip, card and section header, so the six
/// sources stay distinguishable at a glance.
Color bookColor(int bookId, ColorScheme scheme) {
  final accent = QamusTheme.accents[(bookId - 1) % QamusTheme.accents.length];
  if (scheme.brightness != Brightness.dark) return accent;
  // Lift the darker accents so they stay readable on a near-black ground.
  final hsl = HSLColor.fromColor(accent);
  return hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 0.8)).toColor();
}

/// A quiet fade-and-lift page transition.
///
/// Material's default slide is too heavy for a reference app where the reader
/// hops between words constantly; this keeps the motion soft.
class _SoftPageTransition extends PageTransitionsBuilder {
  const _SoftPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}
