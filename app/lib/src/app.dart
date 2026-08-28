import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/bootstrap.dart';
import 'data/dictionary.dart';
import 'data/settings.dart';
import 'theme.dart';
import 'ui/home_page.dart';
import 'ui/setup_page.dart';

/// Hands the opened dictionary and the user's settings down the tree without
/// pulling in a state-management package.
class Qamus extends InheritedNotifier<Settings> {
  const Qamus({
    super.key,
    required this.dictionary,
    required Settings settings,
    required super.child,
  }) : super(notifier: settings);

  final Dictionary dictionary;

  Settings get settings => notifier!;

  static Qamus of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<Qamus>();
    assert(scope != null, 'No Qamus scope found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant Qamus oldWidget) =>
      dictionary != oldWidget.dictionary || super.updateShouldNotify(oldWidget);
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

  @override
  void initState() {
    super.initState();
    _start();
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

  /// The whole app reads right to left, whatever the host platform's locale.
  ///
  /// This also binds Escape to "go back", which desktop users reach for long
  /// before they look for the arrow in the corner. The navigator is addressed
  /// through its key because this builder runs *above* the Navigator, where
  /// `Navigator.of` would find nothing.
  Widget _shell(BuildContext context, Widget? child) => Directionality(
    textDirection: TextDirection.rtl,
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
        child: Focus(autofocus: true, child: child ?? const SizedBox.shrink()),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dictionary = _dictionary;
    final settings = _settings;

    if (dictionary == null || settings == null) {
      return MaterialApp(
        title: 'قاموس المعاني',
        debugShowCheckedModeBanner: false,
        theme: QamusTheme.light(),
        darkTheme: QamusTheme.dark(),
        localizationsDelegates: _delegates,
        locale: const Locale('ar'),
        supportedLocales: _locales,
        builder: _shell,
        home: SetupPage(
          progress: _bootstrap.progress,
          error: _error,
          onRetry: _retry,
        ),
      );
    }

    // The scope sits *above* MaterialApp so that every pushed route — which is
    // a sibling of `home` under the Navigator, not a descendant — can still
    // reach the dictionary and the settings.
    return Qamus(
      dictionary: dictionary,
      settings: settings,
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'قاموس المعاني',
          debugShowCheckedModeBanner: false,
          theme: QamusTheme.light(),
          darkTheme: QamusTheme.dark(),
          themeMode: Qamus.of(context).settings.themeMode,
          localizationsDelegates: _delegates,
          locale: const Locale('ar'),
          supportedLocales: _locales,
          navigatorKey: _navigator,
          builder: _shell,
          home: const HomePage(),
        ),
      ),
    );
  }
}

const _locales = [Locale('ar'), Locale('en')];

const _delegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
