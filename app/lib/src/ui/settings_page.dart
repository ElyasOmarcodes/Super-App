import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../l10n/locales.dart';
import '../theme.dart';
import 'about_page.dart';
import 'books_sheet.dart';
import 'developer_page.dart';
import 'guide_page.dart';
import 'widgets/motion.dart';

/// Language, appearance, reading preferences, sources and credits.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final settings = scope.settings;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 60 * step++),
      child: child,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 150),
          children: [
            Text(strings.navSettings, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 18),

            // --------------------------------------------------- language
            stagger(
              _Group(
                title: strings.language,
                icon: Icons.translate_rounded,
                tint: QamusTheme.blue,
                subtitle: strings.languageDetail,
                children: [
                  for (final locale in AppLocale.values)
                    _LanguageRow(
                      locale: locale,
                      selected: settings.appLocale == locale,
                      onTap: () => settings.setLocale(locale),
                    ),
                ],
              ),
            ),

            // -------------------------------------------------- appearance
            stagger(
              _Group(
                title: strings.appearance,
                icon: Icons.palette_rounded,
                tint: scheme.primary,
                children: [
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded),
                        label: Text(strings.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_rounded),
                        label: Text(strings.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded),
                        label: Text(strings.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (value) =>
                        settings.setThemeMode(value.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------- reading
            stagger(
              _Group(
                title: strings.reading,
                icon: Icons.menu_book_rounded,
                tint: QamusTheme.amber,
                children: [
                  Text(strings.textSize, style: theme.textTheme.titleSmall),
                  Row(
                    children: [
                      const Icon(Icons.text_decrease_rounded, size: 18),
                      Expanded(
                        child: Slider(
                          value: settings.textScale,
                          min: 0.8,
                          max: 1.8,
                          divisions: 10,
                          label: '×${settings.textScale.toStringAsFixed(1)}',
                          onChanged: settings.setTextScale,
                        ),
                      ),
                      const Icon(Icons.text_increase_rounded, size: 22),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      settings.showVowels
                          ? strings.sampleVowelled
                          : strings.sampleBare,
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18 * settings.textScale,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.showVowels,
                    onChanged: settings.setShowVowels,
                    title: Text(
                      strings.showVowels,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      strings.showVowelsDetail,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------- sources
            stagger(
              _Group(
                title: strings.sources,
                icon: Icons.library_books_rounded,
                tint: QamusTheme.rose,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.activeLexicons,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      settings.allBooksSelected
                          ? strings.allSix
                          : '${strings.books(settings.selectedBooks.length)} / '
                                '${strings.n(scope.dictionary.books.length)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showBooksSheet(context),
                  ),
                  const SizedBox(height: 4),
                  for (final book in scope.dictionary.books)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: bookColor(book.id, scheme),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              book.name,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            strings.n(book.count),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ------------------------------------------------------- about
            stagger(
              _Group(
                title: strings.about,
                icon: Icons.info_rounded,
                tint: scheme.tertiary,
                children: [
                  for (final (icon, label, page)
                      in <(IconData, String, Widget)>[
                        (
                          Icons.school_rounded,
                          strings.guide,
                          const GuidePage(),
                        ),
                        (
                          Icons.auto_stories_rounded,
                          strings.aboutProgram,
                          const AboutPage(section: AboutSection.program),
                        ),
                        (
                          Icons.person_rounded,
                          strings.aboutDeveloper,
                          const DeveloperPage(),
                        ),
                        (
                          Icons.lightbulb_rounded,
                          strings.howItWorks,
                          const AboutPage(section: AboutSection.how),
                        ),
                        (
                          Icons.workspace_premium_rounded,
                          strings.licenses,
                          const AboutPage(section: AboutSection.licences),
                        ),
                      ])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(icon, size: 21),
                      title: Text(label, style: theme.textTheme.titleMedium),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => page)),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: scope.dictionary.path),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.pathCopied)),
                      );
                    },
                    icon: const Icon(Icons.folder_copy_rounded, size: 18),
                    label: Text(strings.copyDbPath),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Directionality(
                textDirection: locale.textDirection,
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.nativeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                      Text(
                        locale.englishName,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.icon,
    required this.tint,
    required this.children,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      // A Material, not a DecoratedBox: the ListTiles inside paint their ink
      // on the nearest Material ancestor, and a plain box would hide it.
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QamusTheme.radius),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 17, color: tint),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                ],
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(subtitle!, style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
