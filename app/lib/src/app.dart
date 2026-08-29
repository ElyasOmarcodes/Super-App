import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/bootstrap.dart';
import 'data/dictionary.dart';
import 'data/settings.dart';
import 'l10n/locales.dart';
import 'l10n/strings.dart';
import 'theme.dart';
import 'ui/onboarding/onboarding_flow.dart';
import 'ui/shell.dart';
import 'ui/splash_page.dart';

/// Hands the opened dictionary, the user's settings and the active
/// translations down the tree without pulling in a state-management package.
class Qamus extends InheritedNotifier<Settings> {
  const Qamus({
    super.key,
    required this.dictionary,
    required Settings settings,
    required super.child,
  }) : super(notifier: settings);

  final Dictionary dictionary;

  Settings get settings => notifier!;

  AppLocale get locale => settings.appLocale;

  Strings get strings => Strings(settings.appLocale);

  static Qamus of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<Qamus>();
    assert(scope != null, 'No Qamus scope found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant Qamus oldWidget) =>
      dictionary != oldWidget.dictionary || super.updateShouldNotify(oldWidget);
}

/// Shorthand for the two things almost every widget needs.
extension QamusContext on BuildContext {
  Strings get str => Qamus.of(this).strings;
  Qamus get qamus => Qamus.of(this);
}

class QamusApp extends StatefulWidget {
  const QamusApp({super.key});

  @override
  State<QamusApp> createState() => _QamusAppState();
}

class _QamusAppState extends State<QamusApp> {
  final _bootstrap = DatabaseBootstrap();
  final _navigator = GlobalKey<NavigatorState>();

  Dictionary? _dictionary;
  Settings? _settings;
  Object? _error;

  /// The splash holds for its own entrance even when the dictionary opens
  /// instantly, which it does on every launch after the first. Without this
  /// the screen the app introduces itself with would flash past unread.
  bool _splashSettled = false;

  @override
  void initState() {
    super.initState();
    _start();
    Future<void>.delayed(const Duration(milliseconds: 1750), () {
      if (mounted) setState(() => _splashSettled = true);
    });
  }

  Future<void> _start() async {
    try {
      final path = await _bootstrap.ensureReady();
      final dictionary = await Dictionary.open(path);
      final settings = await Settings.load(dictionary.books.map((b) => b.id));
      if (!mounted) return;
      setState(() {
        _dictionary = dictionary;
        _settings = settings;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  void _retry() {
    setState(() => _error = null);
    _start();
  }

  @override
  void dispose() {
    _bootstrap.dispose();
    _dictionary?.dispose();
    super.dispose();
  }

  /// Applies the chosen language's reading direction and binds Escape to
  /// "go back", which desktop users reach for long before they look for the
  /// arrow in the corner. The navigator is addressed through its key because
  /// this builder runs *above* the Navigator.
  TransitionBuilder _shell(AppLocale locale) =>
      (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: locale.textDirection,
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 1,
            maxScaleFactor: 1.3,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  final navigator = _navigator.currentState;
                  if (navigator != null && navigator.canPop()) navigator.pop();
                },
              },
              child: Focus(
                autofocus: true,
                // On a wide desktop window the app keeps a comfortable
                // reading column rather than stretching a phone layout
                // across two thousand pixels.
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    final dictionary = _dictionary;
    final settings = _settings;

    if (dictionary == null || settings == null || !_splashSettled) {
      return MaterialApp(
        title: 'Qamus',
        debugShowCheckedModeBanner: false,
        theme: QamusTheme.light(),
        darkTheme: QamusTheme.dark(),
        localizationsDelegates: _delegates,
        locale: AppLocale.ar.locale,
        supportedLocales: _supported,
        builder: _shell(AppLocale.ar),
        home: SplashPage(
          progress: _bootstrap.progress,
          error: _error,
          onRetry: _retry,
        ),
      );
    }

    // The scope sits *above* MaterialApp so that every pushed route — which is
    // a sibling of `home` under the Navigator, not a descendant — can still
    // reach the dictionary, the settings and the translations.
    return Qamus(
      dictionary: dictionary,
      settings: settings,
      child: Builder(
        builder: (context) {
          final scope = Qamus.of(context);
          final locale = scope.locale;
          final needsOnboarding =
              scope.settings.chosenLocale == null || !scope.settings.onboarded;

          return MaterialApp(
            title: scope.strings.appName,
            debugShowCheckedModeBanner: false,
            theme: QamusTheme.light(),
            darkTheme: QamusTheme.dark(),
            themeMode: scope.settings.themeMode,
            localizationsDelegates: _delegates,
            locale: locale.locale,
            supportedLocales: _supported,
            navigatorKey: _navigator,
            builder: _shell(locale),
            home: needsOnboarding ? const OnboardingFlow() : const AppShell(),
          );
        },
      ),
    );
  }
}

final _supported = [for (final l in AppLocale.values) l.locale];

const _delegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
