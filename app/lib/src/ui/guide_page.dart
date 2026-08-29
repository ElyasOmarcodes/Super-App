import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import 'deep_search_page.dart';
import 'roots_page.dart';
import 'shell.dart';
import 'widgets/cards.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// The manual, written for someone who has never used a dictionary app.
///
/// Every entry shows the control **as it really is** — the same [ModePill],
/// the same bookmark, the same navigation bar the reader will meet — because
/// a description of a button teaches far less than the button itself.
class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 55 * step.clamp(0, 10)),
      child: child,
    );

    Widget lesson({
      required IconData icon,
      required Color accent,
      required String title,
      required String body,
      String? example,
      required Widget preview,
      VoidCallback? onOpen,
    }) {
      step++;
      return stagger(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _Lesson(
            icon: icon,
            accent: accent,
            title: title,
            body: body,
            example: example,
            preview: preview,
            onOpen: onOpen,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.guide)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 48),
        children: [
          stagger(
            ColourCard(
              accent: QamusTheme.violet,
              watermark: Icons.school_rounded,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.guide,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.guideIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.9,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------ the search box
          SectionTitle(
            strings.guideChapterSearch,
            icon: Icons.search_rounded,
            tint: QamusTheme.violet,
          ),
          lesson(
            icon: Icons.keyboard_rounded,
            accent: QamusTheme.violet,
            title: strings.guideChapterSearch,
            body: strings.guideSearchBody,
            preview: const _SearchBoxPreview(),
          ),

          // ------------------------------------------------- the five modes
          SectionTitle(
            strings.searchModeLabel,
            icon: Icons.tune_rounded,
            tint: QamusTheme.blue,
          ),
          lesson(
            icon: Icons.first_page_rounded,
            accent: QamusTheme.blue,
            title: strings.modeStarts,
            body: strings.guideStartsBody,
            example: strings.guideStartsExample,
            preview: _PillPreview(label: strings.modeStarts),
          ),
          lesson(
            icon: Icons.last_page_rounded,
            accent: QamusTheme.cyan,
            title: strings.modeEnds,
            body: strings.guideEndsBody,
            example: strings.guideEndsExample,
            preview: _PillPreview(label: strings.modeEnds),
          ),
          lesson(
            icon: Icons.search_rounded,
            accent: QamusTheme.emerald,
            title: strings.modeContains,
            body: strings.guideContainsBody,
            example: strings.guideContainsExample,
            preview: _PillPreview(label: strings.modeContains),
          ),
          lesson(
            icon: Icons.check_circle_rounded,
            accent: QamusTheme.amber,
            title: strings.modeExact,
            body: strings.guideExactBody,
            example: strings.guideExactExample,
            preview: _PillPreview(label: strings.modeExact),
          ),
          lesson(
            icon: Icons.account_tree_rounded,
            accent: QamusTheme.rose,
            title: strings.modeRoot,
            body: strings.guideRootBody,
            example: strings.guideRootExample,
            preview: _PillPreview(label: strings.modeRoot),
            onOpen: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const RootsPage())),
          ),

          // ----------------------------------------------- the six lexicons
          SectionTitle(
            strings.lexicons,
            icon: Icons.library_books_rounded,
            tint: QamusTheme.violet,
          ),
          lesson(
            icon: Icons.filter_alt_rounded,
            accent: QamusTheme.violet,
            title: strings.lexicons,
            body: strings.guideBooksBody,
            preview: _BookFilterPreview(label: strings.allBooks),
          ),

          // -------------------------------------------------- deep search
          lesson(
            icon: Icons.travel_explore_rounded,
            accent: QamusTheme.emerald,
            title: strings.deepSearch,
            body: strings.guideDeepBody,
            example: strings.guideDeepExample,
            preview: _DeepSearchPreview(label: strings.deepSearch),
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DeepSearchPage()),
            ),
          ),

          // ---------------------------------------------- the entry page
          SectionTitle(
            strings.definitions,
            icon: Icons.menu_book_rounded,
            tint: QamusTheme.amber,
          ),
          lesson(
            icon: Icons.format_list_numbered_rounded,
            accent: QamusTheme.amber,
            title: strings.guideChapterEntry,
            body: strings.guideEntryBody,
            preview: const _NumberedPreview(),
          ),
          lesson(
            icon: Icons.copy_rounded,
            accent: QamusTheme.blue,
            title: strings.copySense,
            body: strings.guideCopyBody,
            preview: const _CopyPreview(),
          ),
          lesson(
            icon: Icons.bookmark_rounded,
            accent: QamusTheme.rose,
            title: strings.saveWord,
            body: strings.guideSaveBody,
            preview: const _SavePreview(),
          ),

          // ------------------------------------------------- the four tabs
          SectionTitle(
            strings.navHome,
            icon: Icons.dashboard_rounded,
            tint: QamusTheme.cyan,
          ),
          lesson(
            icon: Icons.history_rounded,
            accent: QamusTheme.cyan,
            title: strings.navRecent,
            body: strings.guideRecentBody,
            preview: const _NavPreview(),
          ),

          // --------------------------------------------------- settings
          SectionTitle(
            strings.navSettings,
            icon: Icons.tune_rounded,
            tint: QamusTheme.emerald,
          ),
          lesson(
            icon: Icons.palette_rounded,
            accent: QamusTheme.emerald,
            title: strings.navSettings,
            body: strings.guideSettingsBody,
            preview: const _SettingsPreview(),
          ),
          lesson(
            icon: Icons.translate_rounded,
            accent: QamusTheme.blue,
            title: strings.language,
            body: strings.guideLanguageBody,
            preview: const _LanguagePreview(),
          ),
          lesson(
            icon: Icons.wifi_off_rounded,
            accent: QamusTheme.violet,
            title: strings.guideChapterOffline,
            body: strings.guideOfflineBody,
            preview: const _OfflinePreview(),
          ),

          const SizedBox(height: 12),
          Center(
            child: Text(
              strings.tagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One lesson: the control itself, then what it does, then a worked example.
class _Lesson extends StatelessWidget {
  const _Lesson({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.preview,
    this.example,
    this.onOpen,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final String? example;
  final Widget preview;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = context.str;

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, colour: accent, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 14),

          // The real control, on its own shelf so it reads as a specimen
          // rather than as something to press right now.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Center(child: preview),
          ),

          const SizedBox(height: 14),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.5,
              height: 1.95,
            ),
          ),
          if (example != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
                // A coloured spine on the reading side marks the example
                // out from the explanation above it.
                border: BorderDirectional(
                  start: BorderSide(color: accent, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.guideExampleLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.9),
                  ),
                ],
              ),
            ),
          ],
          if (onOpen != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_outward_rounded, size: 17),
                label: Text(strings.guideOpenIt),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- specimens

class _SearchBoxPreview extends StatelessWidget {
  const _SearchBoxPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return IgnorePointer(
      child: TextField(
        controller: TextEditingController(text: 'رحم'),
        readOnly: true,
        style: theme.textTheme.headlineSmall,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
          suffixIcon: const Icon(Icons.cancel_rounded),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

class _PillPreview extends StatelessWidget {
  const _PillPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: ModePill(label: label, selected: true));
}

class _BookFilterPreview extends StatelessWidget {
  const _BookFilterPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final books = context.qamus.dictionary.books;
    return Column(
      children: [
        IgnorePointer(child: BookFilterPill(label: label, filtered: false)),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final book in books.take(6)) BookChip(book: book, dense: true),
          ],
        ),
      ],
    );
  }
}

class _DeepSearchPreview extends StatelessWidget {
  const _DeepSearchPreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: FloatingActionButton.extended(
      heroTag: null,
      onPressed: () {},
      backgroundColor: QamusTheme.emerald,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.travel_explore_rounded),
      label: Text(label),
    ),
  );
}

/// A miniature of a numbered definition, exactly as the entry page draws it.
class _NumberedPreview extends StatelessWidget {
  const _NumberedPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;
    const colour = QamusTheme.amber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 1; i <= 2; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrdinalBadge(label: strings.n(i), colour: colour, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    i == 1 ? 'الرَّحيمُ: ذو الرَّحمة' : 'رَحُمَ: رَقَّ قلبُه',
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CopyPreview extends StatelessWidget {
  const _CopyPreview();

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);

    Widget one(IconData icon, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: IconButton.filledTonal(
            onPressed: () {},
            icon: Icon(icon, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, style: theme.textTheme.labelMedium, maxLines: 2),
        ),
      ],
    );

    // A Wrap rather than a Row: the two labels are long in every language,
    // and on a narrow phone they belong on separate lines.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 8,
      children: [
        one(Icons.copy_rounded, strings.copySense),
        one(Icons.copy_all_rounded, strings.copyEntry),
      ],
    );
  }
}

class _SavePreview extends StatelessWidget {
  const _SavePreview();

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.bookmark_outline_rounded,
          size: 26,
          color: QamusTheme.rose,
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        const Icon(Icons.bookmark_rounded, size: 26, color: QamusTheme.rose),
        const SizedBox(width: 12),
        Text(strings.navFavourites, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

/// The actual navigation bar, shrunk into the page and made inert.
class _NavPreview extends StatelessWidget {
  const _NavPreview();

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    return IgnorePointer(
      child: SoftNavigationBar(
        index: 2,
        onChanged: (_) {},
        items: [
          (
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            label: strings.navHome,
          ),
          (
            icon: Icons.bookmark_outline_rounded,
            activeIcon: Icons.bookmark_rounded,
            label: strings.navFavourites,
          ),
          (
            icon: Icons.history_rounded,
            activeIcon: Icons.history_toggle_off_rounded,
            label: strings.navRecent,
          ),
          (
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune_rounded,
            label: strings.navSettings,
          ),
        ],
      ),
    );
  }
}

class _SettingsPreview extends StatelessWidget {
  const _SettingsPreview();

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    return IgnorePointer(
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment(
            value: 0,
            icon: const Icon(Icons.light_mode_rounded),
            label: Text(strings.themeLight),
          ),
          ButtonSegment(
            value: 1,
            icon: const Icon(Icons.brightness_auto_rounded),
            label: Text(strings.themeSystem),
          ),
          ButtonSegment(
            value: 2,
            icon: const Icon(Icons.dark_mode_rounded),
            label: Text(strings.themeDark),
          ),
        ],
        selected: const {1},
        onSelectionChanged: (_) {},
        showSelectedIcon: false,
      ),
    );
  }
}

class _LanguagePreview extends StatelessWidget {
  const _LanguagePreview();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _Tag('العربية', QamusTheme.violet),
        _Tag('پښتو', QamusTheme.blue),
        _Tag('فارسی', QamusTheme.cyan),
        _Tag('English', QamusTheme.emerald),
      ],
    ),
  );
}

class _OfflinePreview extends StatelessWidget {
  const _OfflinePreview();

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final theme = Theme.of(context);
    return Column(
      children: [
        const Icon(Icons.wifi_off_rounded, size: 30, color: QamusTheme.violet),
        const SizedBox(height: 8),
        Text(
          '${strings.n(scope.dictionary.entryCount)} · '
          '${strings.books(scope.dictionary.books.length)}',
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.accent);

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: accent.withValues(alpha: 0.35)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: QamusTheme.font,
        fontSize: 12.5,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: accent,
      ),
    ),
  );
}
