@Timeout(Duration(minutes: 6))
library;

import 'dart:async';
import 'dart:ui' show AppExitResponse;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/app.dart';
import 'package:qamus/src/data/corpus.dart';
import 'package:qamus/src/data/dictionary.dart';
import 'package:qamus/src/data/bootstrap.dart';
import 'package:qamus/src/data/notifications.dart';
import 'package:qamus/src/data/settings.dart';
import 'package:qamus/src/developer.dart';
import 'package:qamus/src/l10n/locales.dart';
import 'package:qamus/src/l10n/strings.dart';
import 'package:qamus/src/theme.dart';
import 'package:qamus/src/ui/developer_page.dart';
import 'package:qamus/src/ui/entry_page.dart';
import 'package:qamus/src/ui/guide_page.dart';
import 'package:qamus/src/ui/home_page.dart';
import 'package:qamus/src/ui/library_page.dart';
import 'package:qamus/src/ui/onboarding/onboarding_flow.dart';
import 'package:qamus/src/ui/privacy_page.dart';
import 'package:qamus/src/ui/widgets/app_drawer.dart';
import 'package:qamus/src/ui/roots_page.dart';
import 'package:qamus/src/ui/settings_page.dart';
import 'package:qamus/src/ui/shell.dart';
import 'package:qamus/src/ui/splash_page.dart';
import 'package:qamus/src/ui/widgets/app_mark.dart';
import 'package:qamus/src/ui/widgets/common.dart';
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
    Size? size,
    WordNotifications? notifications,
  }) async {
    // A lazy list only builds what fits the *render surface*; MediaQuery data
    // alone does not resize it. Long pages therefore ask for a tall one.
    if (size != null) {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }
    SharedPreferences.setMockInitialValues(prefs);
    final settings = await Settings.load(dictionary.books.map((b) => b.id));
    await tester.pumpWidget(
      Qamus(
        dictionary: dictionary,
        settings: settings,
        notifications: notifications,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: QamusTheme.light(),
            home: MediaQuery(
              // The rosette and the aurora loop forever, so pumpAndSettle can
              // never finish while they run. Asking for reduced motion — the
              // same signal an accessibility setting sends — stills them.
              data: MediaQueryData(
                size: size ?? const Size(420, 900),
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
          s.developerRole,
          s.developerTeacher,
          s.developerBio,
          s.contactTitle,
          s.contactDetail,
          s.whatsappLabel,
          s.telegramLabel,
          s.emailLabel,
          s.platformsTitle,
          s.teachesTitle,
          s.copyLabel,
          s.copiedToClipboard,
          s.couldNotOpen,
          s.copySense,
          s.senseCopied,
          s.menuLabel,
          s.searchModeLabel,
          s.guide,
          s.guideDetail,
          s.guideIntro,
          s.guideExampleLabel,
          s.guideOpenIt,
          s.guideChapterEntry,
          s.guideChapterOffline,
          s.guideChapterSearch,
          s.guideSearchBody,
          s.guideStartsBody,
          s.guideStartsExample,
          s.guideEndsBody,
          s.guideEndsExample,
          s.guideContainsBody,
          s.guideContainsExample,
          s.guideExactBody,
          s.guideExactExample,
          s.guideRootBody,
          s.guideRootExample,
          s.guideBooksBody,
          s.guideDeepBody,
          s.guideDeepExample,
          s.guideEntryBody,
          s.guideCopyBody,
          s.guideSaveBody,
          s.guideRecentBody,
          s.guideSettingsBody,
          s.guideLanguageBody,
          s.guideOfflineBody,
          s.dailyWord,
          s.dailyWordDetail,
          s.dailyWordAsk,
          s.dailyWordAskDetail,
          s.allowNotifications,
          s.notNow,
          s.notificationTime,
          s.notificationsBlocked,
          s.notificationsUnavailable,
          s.hourLabel(8),
          s.exitTitle,
          s.exitDetail,
          s.exitConfirm,
          s.stay,
          s.privacy,
          s.privacyDetail,
          s.privacyUpdated,
          s.privacyHeading1,
          s.privacyBody1,
          s.privacyHeading2,
          s.privacyBody2,
          s.privacyHeading3,
          s.privacyBody3,
          s.privacyHeading4,
          s.privacyBody4,
          s.privacyHeading5,
          s.privacyBody5,
          s.privacyContact,
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

  group('the entry page', () {
    testWidgets('numbers every definition and offers to copy each one', (
      tester,
    ) async {
      await pumpApp(tester, home: const EntryPage(entryKey: 'كتب'));
      const strings = Strings(AppLocale.ar);

      // One badge and one copy button per definition on screen.
      final badges = find.byType(OrdinalBadge);
      expect(badges, findsWidgets);
      expect(find.text(strings.n(1)), findsWidgets);
      expect(
        find.byTooltip(strings.copySense),
        findsWidgets,
        reason: 'each definition carries its own copy button',
      );

      // They count up rather than all reading "1".
      expect(find.text(strings.n(2)), findsWidgets);
    });

    testWidgets('copying one definition takes its lexicon with it', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpApp(tester, home: const EntryPage(entryKey: 'كتب'));
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.byTooltip(strings.copySense).first);
      await tester.pumpAndSettle();

      expect(copied, isNotNull);
      // The lexicon's own name is on the first line, in brackets.
      expect(copied, startsWith('['));
      final book = dictionary.books.firstWhere(
        (b) => copied!.startsWith('[${b.name}]'),
        orElse: () => dictionary.books.first,
      );
      expect(copied, contains(book.name));
      expect(copied!.trim().split('\n').length, greaterThan(1));
    });
  });

  group('the author', () {
    testWidgets('the profile names him and lists all three ways to reach him', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const DeveloperPage(),
        size: const Size(420, 2600),
      );
      const strings = Strings(AppLocale.ar);

      expect(find.text(Developer.name), findsOneWidget);
      expect(find.text(strings.developerRole), findsWidgets);

      for (final value in [
        Developer.whatsappNumber,
        Developer.telegramHandle,
        Developer.email,
      ]) {
        expect(find.text(value), findsOneWidget, reason: value);
      }
      for (final label in [
        strings.whatsappLabel,
        strings.telegramLabel,
        strings.emailLabel,
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('the platforms he builds for are all three named', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const DeveloperPage(),
        size: const Size(420, 2600),
      );
      for (final platform in ['Android', 'iOS', 'Windows']) {
        expect(find.text(platform), findsOneWidget, reason: platform);
      }
    });

    testWidgets('a contact row copies its address', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpApp(
        tester,
        home: const DeveloperPage(),
        size: const Size(420, 2600),
      );
      await tester.tap(
        find.byTooltip(const Strings(AppLocale.ar).copyLabel).first,
      );
      await tester.pumpAndSettle();
      expect(copied, Developer.whatsappNumber);
    });

    testWidgets('the contact links point at the right services', (_) async {
      expect(Developer.whatsapp.toString(), 'https://wa.me/93766465848');
      expect(Developer.telegram.toString(), 'https://t.me/Elyas_Omar');
      expect(Developer.mail.toString(), 'mailto:${Developer.email}');
    });
  });

  group('the splash screen', () {
    testWidgets('signs the app with its author, its toolkit and its build', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: SplashPage(
          progress: const Stream<BootstrapProgress>.empty(),
          onRetry: () {},
        ),
      );
      const strings = Strings(AppLocale.ar);

      expect(find.text(strings.appName), findsOneWidget);
      expect(find.text(Developer.name), findsOneWidget);
      expect(find.text('By Flutter'), findsOneWidget);
      expect(find.text('v$kAppVersion'), findsOneWidget);
    });

    testWidgets('stays a splash while there is nothing to unpack', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: SplashPage(
          progress: const Stream<BootstrapProgress>.empty(),
          onRetry: () {},
        ),
      );
      // No bar, no stage caption: a returning reader is not told about a
      // database they already have.
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text(const Strings(AppLocale.ar).onceOnly), findsNothing);
    });

    testWidgets('shows the unpacking progress on a first launch', (
      tester,
    ) async {
      final controller = StreamController<BootstrapProgress>.broadcast();
      addTearDown(controller.close);

      await pumpApp(
        tester,
        home: SplashPage(progress: controller.stream, onRetry: () {}),
      );
      controller.add(const BootstrapProgress(BootstrapStage.indexing, 0.5));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text(const Strings(AppLocale.ar).indexing), findsOneWidget);
    });
  });

  group('the guide', () {
    testWidgets('shows each search mode as the very pill the reader taps', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const GuidePage(),
        size: const Size(420, 7000),
      );
      const strings = Strings(AppLocale.ar);

      // Not a drawing of a pill — the same widget class the search bar uses.
      expect(find.byType(ModePill), findsNWidgets(5));
      for (final label in [
        strings.modeStarts,
        strings.modeEnds,
        strings.modeContains,
        strings.modeExact,
        strings.modeRoot,
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('every mode is explained with a worked example', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const GuidePage(),
        size: const Size(420, 7000),
      );
      const strings = Strings(AppLocale.ar);

      for (final example in [
        strings.guideStartsExample,
        strings.guideEndsExample,
        strings.guideContainsExample,
        strings.guideExactExample,
        strings.guideRootExample,
        strings.guideDeepExample,
      ]) {
        expect(find.text(example), findsOneWidget, reason: example);
      }
    });

    testWidgets('the explanations avoid the jargon they used to lean on', (
      tester,
    ) async {
      // The reader asked for language a child could follow; these are the
      // words the old "how it works" text reached for.
      const jargon = ['SQLite', 'deflate', 'B-tree', 'isolate', 'LZMA'];
      for (final locale in AppLocale.values) {
        final s = Strings(locale);
        final text = [
          s.guideIntro,
          s.guideSearchBody,
          s.guideStartsBody,
          s.guideEndsBody,
          s.guideContainsBody,
          s.guideExactBody,
          s.guideRootBody,
          s.guideBooksBody,
          s.guideDeepBody,
          s.guideEntryBody,
          s.guideCopyBody,
          s.guideSaveBody,
          s.guideRecentBody,
          s.guideSettingsBody,
          s.guideLanguageBody,
          s.guideOfflineBody,
        ].join(' ');
        for (final word in jargon) {
          expect(
            text.toLowerCase().contains(word.toLowerCase()),
            isFalse,
            reason: '"$word" in ${locale.code}',
          );
        }
      }
    });
  });

  group('the navigation curtain', () {
    testWidgets('stands exactly as tall as the bar that floats on it', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.byType(NavigationScrim), findsOneWidget);
      final context = tester.element(find.byType(NavigationScrim));
      final scrim = tester.getSize(find.byType(NavigationScrim));
      expect(scrim.height, navigationBarHeight(context));

      // And it sits under the bar, not over it: nothing about the curtain
      // may swallow a tab tap.
      const strings = Strings(AppLocale.ar);
      await tester.tap(find.text(strings.navSettings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('every tab names itself for a long press', (tester) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);
      for (final label in [
        strings.navHome,
        strings.navFavourites,
        strings.navRecent,
        strings.navSettings,
      ]) {
        expect(find.byTooltip(label), findsOneWidget, reason: label);
      }
    });
  });

  group('leaving the app', () {
    testWidgets('back on the home tab asks before closing', (tester) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      // The system back gesture, as the framework delivers it.
      final popped = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(popped, isTrue, reason: 'the shell handled the pop itself');
      expect(find.text(strings.exitTitle), findsOneWidget);
      expect(find.text(strings.exitDetail), findsOneWidget);
      expect(find.text(strings.stay), findsOneWidget);
      expect(find.text(strings.exitConfirm), findsOneWidget);
    });

    testWidgets('staying dismisses the dialog and keeps the app', (
      tester,
    ) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.stay));
      await tester.pumpAndSettle();

      expect(find.text(strings.exitTitle), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('the desktop window close button asks too', (tester) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      // What a window manager sends when the X is clicked.
      final response = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      expect(find.text(strings.exitTitle), findsOneWidget);

      await tester.tap(find.text(strings.stay));
      await tester.pumpAndSettle();
      expect(await response, AppExitResponse.cancel);
    });

    testWidgets('back from another tab returns home rather than asking', (
      tester,
    ) async {
      await pumpApp(tester);
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.text(strings.navSettings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // No question: the reader asked to go back, not to leave.
      expect(find.text(strings.exitTitle), findsNothing);
      expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack).first).index,
        0,
      );
    });
  });

  group('the sidebar', () {
    testWidgets('lists the sources below every option', (tester) async {
      await pumpApp(tester, size: const Size(420, 2400));
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      // The other tabs are alive behind the drawer, so every finder is
      // scoped to the drawer itself.
      Finder inDrawer(String label) => find.descendant(
        of: find.byType(AppDrawer),
        matching: find.text(label),
      );
      double topOf(Finder finder) => tester.getTopLeft(finder).dy;

      final sources = topOf(inDrawer(strings.sources));
      for (final option in [
        strings.browseRoots,
        strings.deepSearch,
        strings.guide,
        strings.aboutProgram,
        strings.aboutDeveloper,
        strings.howItWorks,
        strings.privacy,
        strings.licenses,
      ]) {
        expect(
          topOf(inDrawer(option).first),
          lessThan(sources),
          reason: '"\$option" should sit above the sources',
        );
      }
    });
  });

  group('the privacy policy', () {
    testWidgets('answers the questions a store listing has to answer', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const PrivacyPage(),
        size: const Size(420, 3200),
      );
      const strings = Strings(AppLocale.ar);

      for (final heading in [
        strings.privacyHeading1,
        strings.privacyHeading2,
        strings.privacyHeading3,
        strings.privacyHeading4,
        strings.privacyHeading5,
      ]) {
        expect(find.text(heading), findsOneWidget, reason: heading);
      }
      expect(find.textContaining(PrivacyPage.lastUpdated), findsOneWidget);
      expect(find.text(Developer.email), findsOneWidget);
    });

    testWidgets('reads the same in every language', (tester) async {
      for (final locale in AppLocale.values) {
        final text = privacyPolicyAsText(Strings(locale));
        expect(text.trim(), isNotEmpty, reason: locale.code);
        expect(text, contains(Developer.email), reason: locale.code);
      }
    });

    testWidgets('the hosted copy says the same thing as the app', (_) async {
      // Google Play reads docs/privacy-policy.md at a public URL while the
      // reader reads the page inside the app. They have to agree.
      final hosted = File('../docs/privacy-policy.md').readAsStringSync();
      expect(hosted, contains(PrivacyPage.lastUpdated));
      expect(hosted, contains(Developer.email));
      for (final locale in AppLocale.values) {
        final s = Strings(locale);
        for (final heading in [
          s.privacyHeading1,
          s.privacyHeading2,
          s.privacyHeading3,
          s.privacyHeading4,
          s.privacyHeading5,
        ]) {
          expect(
            hosted,
            contains(heading),
            reason: '\${locale.code}: \$heading',
          );
        }
      }
    });
  });

  group('the word of the day', () {
    testWidgets('is the same word all day, and a different one tomorrow', (
      _,
    ) async {
      final morning = dictionary.wordOfDay(DateTime(2026, 8, 29, 6));
      final evening = dictionary.wordOfDay(DateTime(2026, 8, 29, 23));
      final tomorrow = dictionary.wordOfDay(DateTime(2026, 8, 30, 6));

      expect(morning, isNotNull);
      expect(morning!.key, evening!.key);
      expect(morning.key, isNot(tomorrow!.key));
      expect(morning.word.trim(), isNotEmpty);
    });

    testWidgets('the settings switch is off until it is asked for', (
      tester,
    ) async {
      final settings = await pumpApp(
        tester,
        home: const SettingsPage(),
        size: const Size(420, 2400),
      );
      const strings = Strings(AppLocale.ar);

      expect(settings.dailyWord, isFalse);
      expect(find.text(strings.dailyWord), findsWidgets);

      final daily = _switchTitled(strings.dailyWord);
      expect(daily, findsOneWidget);
      expect(tester.widget<SwitchListTile>(daily).value, isFalse);
    });

    testWidgets('a platform that cannot schedule says so plainly', (
      tester,
    ) async {
      // Linux can post a notification but cannot schedule one, so the switch
      // is disabled rather than left on promising a word that never comes.
      await pumpApp(
        tester,
        home: const SettingsPage(),
        size: const Size(420, 2400),
        notifications: WordNotifications.disabled(available: false),
      );
      const strings = Strings(AppLocale.ar);

      final daily = _switchTitled(strings.dailyWord);
      expect(tester.widget<SwitchListTile>(daily).onChanged, isNull);
      expect(find.text(strings.notificationsUnavailable), findsOneWidget);
    });

    testWidgets('a refused permission leaves the switch off', (tester) async {
      // The scope's default service refuses everything, which is exactly what
      // a reader who declines the system dialog produces.
      final settings = await pumpApp(
        tester,
        home: const SettingsPage(),
        size: const Size(420, 2400),
      );
      const strings = Strings(AppLocale.ar);

      await tester.tap(_switchTitled(strings.dailyWord));
      await tester.pumpAndSettle();

      expect(settings.dailyWord, isFalse);
      expect(find.text(strings.notificationsBlocked), findsOneWidget);
    });

    testWidgets('onboarding asks for consent after the intro, not before', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: const OnboardingFlow(),
        prefs: {'locale': 'ar'},
        size: const Size(420, 1400),
      );
      const strings = Strings(AppLocale.ar);

      // Straight into the intro, because the language is already chosen.
      expect(find.text(strings.introTitle1), findsOneWidget);
      expect(find.text(strings.dailyWordAsk), findsNothing);

      await tester.tap(find.text(strings.skip));
      await tester.pumpAndSettle();

      expect(find.text(strings.dailyWordAsk), findsOneWidget);
      expect(find.text(strings.allowNotifications), findsOneWidget);
      expect(find.text(strings.notNow), findsOneWidget);
    });

    testWidgets('"not now" still lets the reader in', (tester) async {
      final settings = await pumpApp(
        tester,
        home: const OnboardingFlow(),
        prefs: {'locale': 'ar'},
        size: const Size(420, 1400),
      );
      const strings = Strings(AppLocale.ar);

      await tester.tap(find.text(strings.skip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.notNow));
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(settings.onboarded, isTrue);
      expect(settings.dailyWord, isFalse);
    });
  });

  group('the mark', () {
    testWidgets('the splash turns the launcher icon into a progress ring', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: SplashPage(
          progress: const Stream<BootstrapProgress>.empty(),
          onRetry: () {},
        ),
      );

      expect(find.byType(AppMark), findsOneWidget);
      expect(tester.widget<AppMark>(find.byType(AppMark)).progress, isTrue);
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      // Reduced motion is on in these tests, so the arc holds still rather
      // than spinning forever — the same picture the icon shows.
      expect(ring.value, isNotNull);
    });

    testWidgets('the sidebar and the language picker wear the same mark', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AppMark), findsOneWidget);

      await pumpApp(tester, home: const OnboardingFlow());
      expect(find.byType(AppMark), findsOneWidget);
      // No ring anywhere but the splash: nothing is loading here.
      expect(tester.widget<AppMark>(find.byType(AppMark)).progress, isFalse);
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

      // Two switches live on this page now — the diacritics one is the one
      // carrying that label.
      final diacritics = find.ancestor(
        of: find.text(strings.showVowels),
        matching: find.byType(SwitchListTile),
      );
      await tester.scrollUntilVisible(diacritics, 240);
      await tester.pumpAndSettle();
      expect(find.text(strings.sampleVowelled), findsOneWidget);

      await tester.tap(diacritics);
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

/// The one switch on the settings page whose title reads [label].
///
/// The group heading above it carries the same words, so matching on text
/// alone finds two things and taps neither.
Finder _switchTitled(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is SwitchListTile &&
      widget.title is Text &&
      (widget.title! as Text).data == label,
);
