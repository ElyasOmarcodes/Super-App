@Timeout(Duration(minutes: 6))
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/app.dart';
import 'package:qamus/src/data/corpus.dart';
import 'package:qamus/src/data/dictionary.dart';
import 'package:qamus/src/data/settings.dart';
import 'package:qamus/src/l10n/locales.dart';
import 'package:qamus/src/l10n/strings.dart';
import 'package:qamus/src/theme.dart';
import 'package:qamus/src/ui/entry_page.dart';
import 'package:qamus/src/ui/home_page.dart';
import 'package:qamus/src/ui/library_page.dart';
import 'package:qamus/src/ui/onboarding/onboarding_flow.dart';
import 'package:qamus/src/ui/roots_page.dart';
import 'package:qamus/src/ui/settings_page.dart';
import 'package:qamus/src/ui/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real widget tree against the real corpus.
///
/// The point of these is navigation and localisation: a pushed route is a
/// sibling of `home` under the Navigator, so anything reading the dictionary
/// through an inherited scope has to find that scope *above* MaterialApp.
void main() {
  late Directory workspace;
  late Dictionary dictionary;

  setUpAll(() async {
    workspace = Directory.systemTemp.createTempSync('qamus-widget-test');
    final target = '${workspace.path}/qamus.db';
    buildDatabase(
      Uint8List.fromList(
        XZDecoder().decodeBytes(
          File('assets/db/qamus.corpus.xz').readAsBytesSync(),
        ),
      ),
      target,
      (_, _) {},
    );
    dictionary = await Dictionary.open(target);
  });

  tearDownAll(() {
    dictionary.dispose();
    workspace.deleteSync(recursive: true);
  });

  Future<Settings> pumpApp(
    WidgetTester tester, {
    Widget home = const AppShell(),
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final settings = await Settings.load(dictionary.books.map((b) => b.id));
    await tester.pumpWidget(
      Qamus(
        dictionary: dictionary,
        settings: settings,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: QamusTheme.light(),
            home: MediaQuery(
              // The rosette and the aurora loop forever, so pumpAndSettle can
              // never finish while they run. Asking for reduced motion — the
              // same signal an accessibility setting sends — stills them.
              data: const MediaQueryData(
                size: Size(420, 900),
                disableAnimations: true,
              ),
              child: Directionality(
                textDirection: Qamus.of(context).locale.textDirection,
                child: home,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return settings;
  }

  group('shell', () {
    testWidgets('opens on the home tab with the corpus at a glance', (
      tester,
    ) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);
      expect(find.text(strings.appName), findsWidgets);
      expect(find.text(strings.browseRoots), findsWidgets);
      expect(find.byType(SoftNavigationBar), findsOneWidget);
    });

    testWidgets('each bottom-nav tab reaches its page', (tester) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.text(strings.navFavourites));
      await tester.pumpAndSettle();
      expect(find.text(strings.noFavourites), findsOneWidget);

      await tester.tap(find.text(strings.navRecent));
      await tester.pumpAndSettle();
      expect(find.byType(LibraryView), findsWidgets);

      await tester.tap(find.text(strings.navSettings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.text(strings.navHome));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('the sidebar opens and lists the about topics', (tester) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text(strings.browseRoots), findsWidgets);
      await tester.scrollUntilVisible(
        find.text(strings.aboutProgram),
        220,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text(strings.aboutProgram), findsOneWidget);
      expect(find.text(strings.aboutDeveloper), findsOneWidget);
      expect(find.text(strings.howItWorks), findsOneWidget);
    });
  });

  group('search', () {
    testWidgets('typing runs a live search and a hit opens the entry', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).first, 'كتب');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byType(EntryPage), findsNothing);
      expect(find.textContaining('يبدأ بـ'), findsWidgets);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await tester.pumpAndSettle();

      // The regression this guards: the entry page resolves the dictionary
      // through the inherited scope from inside a pushed route.
      expect(find.byType(EntryPage), findsOneWidget);
    });

    testWidgets('an unknown headword degrades gracefully', (tester) async {
      await pumpApp(tester, home: const EntryPage(entryKey: 'زززززز'));
      expect(find.text(const Strings(AppLocale.ar).notFound), findsOneWidget);
    });

    testWidgets('the root browser lists derivations', (tester) async {
      await pumpApp(tester, home: const RootsPage());
      const strings = Strings(AppLocale.ar);
      expect(find.text(strings.chooseRoot), findsOneWidget);

      await tester.tap(find.byType(ChoiceChip).first);
      await tester.pumpAndSettle();
      expect(find.textContaining('مشتقّات'), findsOneWidget);
    });
  });

  group('localisation', () {
    testWidgets('switching language retranslates the whole interface', (
      tester,
    ) async {
      final settings = await pumpApp(
        tester,
        home: const AppShell(),
        prefs: {'locale': 'ar', 'onboarded': true},
      );
      expect(find.text(const Strings(AppLocale.ar).navHome), findsOneWidget);

      for (final locale in AppLocale.values) {
        await settings.setLocale(locale);
        await tester.pumpAndSettle();
        final strings = Strings(locale);
        expect(
          find.text(strings.navHome),
          findsOneWidget,
          reason: 'home tab in ${locale.code}',
        );
        expect(
          find.text(strings.navSettings),
          findsOneWidget,
          reason: 'settings tab in ${locale.code}',
        );
      }
    });

    testWidgets('English lays the app out left to right', (tester) async {
      final settings = await pumpApp(tester, prefs: {'onboarded': true});
      await settings.setLocale(AppLocale.en);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'كتب');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      // Material's chevron carries matchTextDirection, so one icon serves
      // both directions — picking it by direction as well flips it back.
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    });

    testWidgets('every language renders digits in its own numerals', (
      tester,
    ) async {
      expect(const Strings(AppLocale.ar).n(2026), '٢٬٠٢٦');
      expect(const Strings(AppLocale.fa).n(2026), '۲٬۰۲۶');
      expect(const Strings(AppLocale.ps).n(2026), '۲٬۰۲۶');
      expect(const Strings(AppLocale.en).n(2026), '2,026');
    });

    testWidgets('Arabic counted nouns agree with the number', (tester) async {
      const ar = Strings(AppLocale.ar);
      expect(ar.books(1), 'معجم واحد');
      expect(ar.books(2), 'معجمان');
      expect(ar.books(6), '٦ معاجم');
      expect(ar.entries(11), '١١ مدخلًا');
      // The bug this guards: "١ معاجم" is ungrammatical.
      expect(ar.books(1).startsWith('١'), isFalse);
    });

    testWidgets('no translation is left empty', (tester) async {
      for (final locale in AppLocale.values) {
        final s = Strings(locale);
        final values = <String>[
          s.appName,
          s.tagline,
          s.chooseLanguage,
          s.chooseLanguageDetail,
          s.continueLabel,
          s.skip,
          s.next,
          s.start,
          s.introTitle1,
          s.introBody1,
          s.introTitle2,
          s.introBody2,
          s.introTitle3,
          s.introBody3,
          s.navHome,
          s.navFavourites,
          s.navRecent,
          s.navSettings,
          s.searchHint,
          s.clear,
          s.modeStarts,
          s.modeEnds,
          s.modeContains,
          s.modeExact,
          s.modeRoot,
          s.allBooks,
          s.noResults,
          s.noResultsDetail,
          s.searchingLabel,
          s.browseRoots,
          s.browseRootsDetail,
          s.deepSearch,
          s.deepSearchDetail,
          s.treasures,
          s.recentSearches,
          s.saved,
          s.suffixTip,
          s.lexicons,
          s.lexiconsDetail,
          s.selectAll,
          s.thesaurus,
          s.definitions,
          s.fromRoot,
          s.similarWords,
          s.copyEntry,
          s.copied,
          s.saveWord,
          s.unsaveWord,
          s.showAll,
          s.notFound,
          s.noDefinition,
          s.rootsTitle,
          s.rootHint,
          s.chooseRoot,
          s.chooseRootDetail,
          s.noRoots,
          s.deepSearchHint,
          s.deepSearchEmpty,
          s.deepSearchEmptyDetail,
          s.deepSearchRunning,
          s.deepSearchRunningDetail,
          s.stop,
          s.search,
          s.noFavourites,
          s.noFavouritesDetail,
          s.noHistory,
          s.noHistoryDetail,
          s.clearHistory,
          s.appearance,
          s.themeLight,
          s.themeSystem,
          s.themeDark,
          s.reading,
          s.textSize,
          s.showVowels,
          s.showVowelsDetail,
          s.language,
          s.languageDetail,
          s.sources,
          s.activeLexicons,
          s.allSix,
          s.about,
          s.aboutProgram,
          s.aboutDeveloper,
          s.howItWorks,
          s.licenses,
          s.fontLicenses,
          s.copyDbPath,
          s.pathCopied,
          s.version,
          s.aboutDeveloperBody,
          s.howItWorksBody,
          s.preparing,
          s.unpacking,
          s.writingDb,
          s.indexing,
          s.ready,
          s.setupFailed,
          s.retry,
          s.onceOnly,
          s.entriesLabel,
          s.rootsLabel,
          s.lexiconsLabel,
          s.rootOf('كتب'),
          s.derivativesOf('كتب'),
          s.aboutProgramBody('1', '6'),
          s.hiddenSenses(3),
          s.resultHeader(3, 'x', 'y'),
        ];
        for (final value in values) {
          expect(
            value.trim(),
            isNotEmpty,
            reason: 'empty string in ${locale.code}',
          );
        }
      }
    });
  });

  group('onboarding', () {
    testWidgets('a first launch asks for a language before anything else', (
      tester,
    ) async {
      await pumpApp(tester, home: const OnboardingFlow());
      const strings = Strings(AppLocale.ar);
      expect(find.text(strings.chooseLanguage), findsOneWidget);
      for (final locale in AppLocale.values) {
        expect(find.text(locale.nativeName), findsWidgets, reason: locale.code);
      }
    });

    testWidgets('picking a language re-labels the screen in it', (
      tester,
    ) async {
      await pumpApp(tester, home: const OnboardingFlow());
      await tester.tap(find.text(AppLocale.en.nativeName));
      await tester.pumpAndSettle();
      expect(
        find.text(const Strings(AppLocale.en).chooseLanguage),
        findsOneWidget,
      );
    });

    testWidgets('choosing a language leads to the intro pages', (tester) async {
      final settings = await pumpApp(tester, home: const OnboardingFlow());
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.text(AppLocale.ar.nativeName));
      await tester.pumpAndSettle();

      // The picker scrolls on a short surface, so bring the button into view.
      await tester.ensureVisible(find.text(strings.continueLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.continueLabel));
      await tester.pumpAndSettle();

      expect(settings.chosenLocale, AppLocale.ar);
      expect(find.text(strings.introTitle1), findsOneWidget);
      expect(find.text(strings.skip), findsOneWidget);
    });

    testWidgets('a returning reader skips onboarding entirely', (tester) async {
      final settings = await pumpApp(
        tester,
        home: const AppShell(),
        prefs: {'locale': 'ps', 'onboarded': true},
      );
      expect(settings.chosenLocale, AppLocale.ps);
      expect(settings.onboarded, isTrue);
      expect(find.text(const Strings(AppLocale.ps).navHome), findsOneWidget);
    });
  });

  group('preferences', () {
    testWidgets('hiding diacritics changes the sample immediately', (
      tester,
    ) async {
      final settings = await pumpApp(tester, home: const SettingsPage());
      const strings = Strings(AppLocale.ar);
      expect(settings.showVowels, isTrue);

      await tester.scrollUntilVisible(find.byType(SwitchListTile), 240);
      await tester.pumpAndSettle();
      expect(find.text(strings.sampleVowelled), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(settings.showVowels, isFalse);
      expect(find.text(strings.sampleBare), findsOneWidget);
    });

    testWidgets('narrowing the book filter is reflected in the chip', (
      tester,
    ) async {
      final settings = await pumpApp(tester);
      final wasit = dictionary.books.firstWhere((b) => b.name == 'معجم الوسيط');
      await settings.setBooks({wasit.id});
      await tester.pumpAndSettle();

      expect(settings.allBooksSelected, isFalse);
      expect(find.text(wasit.name), findsWidgets);
      // A single selection must never render as the ungrammatical "١ معاجم".
      expect(find.text('١ معاجم'), findsNothing);
    });
  });
}
