import 'package:flutter/material.dart';

import '../../app.dart';
import '../../developer.dart';
import '../../theme.dart';
import '../about_page.dart';
import '../deep_search_page.dart';
import '../developer_page.dart';
import '../guide_page.dart';
import '../roots_page.dart';
import 'motion.dart';

/// The sidebar on the home screen: the ways into the lexicon that are not a
/// search box, plus everything about the app itself.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    void go(Widget page) {
      Navigator.of(context)
        ..pop()
        ..push(MaterialPageRoute<void>(builder: (_) => page));
    }

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 40 * step++),
      offset: const Offset(0.06, 0),
      child: child,
    );

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(title: strings.appName, subtitle: strings.tagline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                children: [
                  stagger(_Section(strings.lexicons)),
                  stagger(
                    _Tile(
                      icon: Icons.account_tree_rounded,
                      tint: scheme.primary,
                      title: strings.browseRoots,
                      subtitle: strings.browseRootsDetail,
                      onTap: () => go(const RootsPage()),
                    ),
                  ),
                  stagger(
                    _Tile(
                      icon: Icons.travel_explore_rounded,
                      tint: QamusTheme.amber,
                      title: strings.deepSearch,
                      subtitle: strings.deepSearchDetail,
                      onTap: () => go(const DeepSearchPage()),
                    ),
                  ),
                  stagger(_Section(strings.sources)),
                  for (final book in scope.dictionary.books)
                    stagger(
                      _BookRow(
                        name: book.name,
                        count: strings.n(book.count),
                        colour: bookColor(book.id, scheme),
                      ),
                    ),
                  stagger(_Section(strings.about)),
                  stagger(
                    _Tile(
                      icon: Icons.school_rounded,
                      tint: QamusTheme.emerald,
                      title: strings.guide,
                      subtitle: strings.guideDetail,
                      onTap: () => go(const GuidePage()),
                    ),
                  ),
                  stagger(
                    _Tile(
                      icon: Icons.info_rounded,
                      tint: QamusTheme.blue,
                      title: strings.aboutProgram,
                      onTap: () =>
                          go(const AboutPage(section: AboutSection.program)),
                    ),
                  ),
                  stagger(
                    _Tile(
                      icon: Icons.person_rounded,
                      tint: QamusTheme.rose,
                      title: strings.aboutDeveloper,
                      subtitle: Developer.name,
                      onTap: () => go(const DeveloperPage()),
                    ),
                  ),
                  stagger(
                    _Tile(
                      icon: Icons.lightbulb_rounded,
                      tint: scheme.tertiary,
                      title: strings.howItWorks,
                      onTap: () =>
                          go(const AboutPage(section: AboutSection.how)),
                    ),
                  ),
                  stagger(
                    _Tile(
                      icon: Icons.workspace_premium_rounded,
                      tint: scheme.primary,
                      title: strings.licenses,
                      onTap: () =>
                          go(const AboutPage(section: AboutSection.licences)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: Text(
                '${strings.version} $kAppVersion',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: 0.16),
            QamusTheme.amber.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Rosette(
            size: 62,
            child: Text(
              'ق',
              style: TextStyle(
                fontFamily: QamusTheme.font,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.labelSmall, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 18, 12, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: tint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({
    required this.name,
    required this.count,
    required this.colour,
  });

  final String name;
  final String count;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(count, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
