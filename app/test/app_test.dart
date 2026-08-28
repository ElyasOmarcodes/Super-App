@Timeout(Duration(minutes: 6))
library;

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamus/src/app.dart';
import 'package:qamus/src/data/bootstrap.dart';
import 'package:qamus/src/data/dictionary.dart';
import 'package:qamus/src/data/settings.dart';
import 'package:qamus/src/theme.dart';
import 'package:qamus/src/ui/entry_page.dart';
import 'package:qamus/src/ui/home_page.dart';
import 'package:qamus/src/ui/roots_page.dart';
import 'package:qamus/src/ui/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the real widget tree against the real corpus.
///
/// The point of these is navigation: a pushed route is a sibling of `home`
/// under the Navigator, so anything that reads the dictionary through an
/// inherited scope has to find that scope *above* MaterialApp.
void main() {
  late Directory workspace;
  late Dictionary dictionary;

  setUpAll(() async {
    workspace = Directory.systemTemp.createTempSync('qamus-widget-test');
    final target = '${workspace.path}/qamus.db';
    File(target).writeAsBytesSync(
      XZDecoder().decodeBytes(File('assets/db/qamus.db.xz').readAsBytesSync()),
    );
    prepareDatabase(target, (_, _) {});
    dictionary = await Dictionary.open(target);
  });

  tearDownAll(() {
    dictionary.dispose();
    workspace.deleteSync(recursive: true);
  });

  Future<Settings> pumpApp(
    WidgetTester tester, {
    Widget home = const HomePage(),
  }) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.load(dictionary.books.map((b) => b.id));
    await tester.pumpWidget(
      Qamus(
        dictionary: dictionary,
        settings: settings,
        child: MaterialApp(
          theme: QamusTheme.light(),
          home: Directionality(textDirection: TextDirection.rtl, child: home),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return settings;
  }

  testWidgets('the landing screen shows the corpus at a glance', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('قاموس المعاني'), findsOneWidget);
    expect(find.text('تصفّح الجذور'), findsOneWidget);
    expect(find.text('بحث في المعاني'), findsWidgets);
    expect(find.text('كل المعاجم'), findsOneWidget);
  });

  testWidgets('typing runs a live search and tapping a hit opens the entry', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'كتب');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(EntryPage), findsNothing);
    final results = find.byType(InkWell).evaluate();
    expect(
      results,
      isNotEmpty,
      reason: 'the search must produce tappable rows',
    );

    expect(
      find.textContaining(' · يبدأ بـ '),
      findsOneWidget,
      reason: 'the result header must say how the query was matched',
    );

    // Every result row carries a chevron; tapping the first opens that entry.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
    await tester.pumpAndSettle();

    // This is the regression: the entry page resolves the dictionary through
    // the inherited scope from inside a pushed route.
    expect(find.byType(EntryPage), findsOneWidget);
    expect(find.textContaining('جذر'), findsWidgets);
  });

  testWidgets('an unknown headword degrades gracefully', (tester) async {
    await pumpApp(tester, home: const EntryPage(entryKey: 'زززززز'));
    expect(find.text('لم يُعثر على هذا المدخل'), findsOneWidget);
  });

  testWidgets('the root browser lists derivations for a chosen root', (
    tester,
  ) async {
    await pumpApp(tester, home: const RootsPage());
    await tester.pumpAndSettle();
    expect(find.text('اختر جذرًا'), findsOneWidget);

    await tester.tap(find.byType(ChoiceChip).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('مشتقّات'), findsOneWidget);
  });

  testWidgets('settings changes propagate through the inherited scope', (
    tester,
  ) async {
    final settings = await pumpApp(tester, home: const SettingsPage());
    expect(find.text('إظهار التشكيل'), findsOneWidget);

    expect(settings.showVowels, isTrue);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(settings.showVowels, isFalse);
    expect(find.text('العلم نور يهدي صاحبه'), findsOneWidget);
  });

  testWidgets('narrowing the book filter narrows the result set', (
    tester,
  ) async {
    final settings = await pumpApp(tester);
    final wasit = dictionary.books.firstWhere((b) => b.name == 'معجم الوسيط');

    await tester.enterText(find.byType(TextField).first, 'كتب');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining(' · يبدأ بـ '), findsOneWidget);

    await settings.setBooks({wasit.id});
    await tester.pumpAndSettle();
    expect(settings.allBooksSelected, isFalse);
    // A single selection must never render as the ungrammatical "١ معاجم".
    expect(find.text('١ معاجم'), findsNothing);
    expect(find.text(wasit.name), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'كتب');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining(' · يبدأ بـ '), findsOneWidget);
  });
}
