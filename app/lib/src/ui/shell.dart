import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../l10n/strings.dart';
import 'favourites_page.dart';
import 'home_page.dart';
import 'recent_page.dart';
import 'settings_page.dart';
import 'widgets/app_drawer.dart';
import 'widgets/exit_dialog.dart';

/// The four-tab frame the whole app lives in.
///
/// Tabs keep their state and scroll position across switches, so hopping to
/// the settings and back never costs the reader their search.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;

  /// The drawer lives on the *shell's* Scaffold, not the home page's, so it
  /// covers the navigation bar instead of sliding in underneath it.
  final _scaffold = GlobalKey<ScaffoldState>();

  /// Guards against a second dialog while the first is still on screen — a
  /// double tap on the window's close button would otherwise stack two.
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The desktop window's close button, and anything else that asks the app
  /// to quit. Android's back gesture arrives through [PopScope] instead.
  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (!mounted || _asking) return AppExitResponse.cancel;
    _asking = true;
    try {
      return await confirmExit(context)
          ? AppExitResponse.exit
          : AppExitResponse.cancel;
    } finally {
      _asking = false;
    }
  }

  Future<void> _handleBack() async {
    // Anywhere but the home tab, back should mean "home" — leaving from
    // the settings screen would surprise anyone.
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    if (_asking) return;
    _asking = true;
    try {
      if (await confirmExit(context)) await leaveApp();
    } finally {
      _asking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.str;

    return PopScope(
      // The root of the stack: a back gesture here means "close the app", so
      // it is intercepted and put to the reader as a question.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: _buildShell(context, strings),
    );
  }

  Widget _buildShell(BuildContext context, Strings strings) {
    return Scaffold(
      key: _scaffold,
      extendBody: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: [
              HomePage(onOpenMenu: () => _scaffold.currentState?.openDrawer()),
              const FavouritesPage(),
              const RecentPage(),
              const SettingsPage(),
            ],
          ),
          // The curtain: opaque at the floor, clear at its top edge, exactly
          // as tall as the bar that floats on it. Content scrolling behind
          // the navigation dissolves into the background instead of running
          // into it.
          const PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: IgnorePointer(child: NavigationScrim()),
          ),
        ],
      ),
      bottomNavigationBar: SoftNavigationBar(
        index: _index,
        onChanged: (i) {
          if (i == _index) return;
          // The small tick a native app gives when a tab actually changes.
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
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

typedef NavItem = ({IconData icon, IconData activeIcon, String label});

/// How tall [SoftNavigationBar] stands, including the gap it keeps from the
/// bottom of the screen and whatever the system reserves below it.
double navigationBarHeight(BuildContext context) =>
    66 + 12 + MediaQuery.paddingOf(context).bottom;

/// The gradient curtain the navigation bar sits on.
///
/// Its own height matches the bar exactly, and it fades from the page's
/// background colour at the floor to nothing at its top edge, so a list
/// scrolling underneath the bar disappears rather than colliding with it.
class NavigationScrim extends StatelessWidget {
  const NavigationScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return SizedBox(
      height: navigationBarHeight(context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              surface,
              surface.withValues(alpha: 0.92),
              surface.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
      ),
    );
  }
}

/// A floating, translucent navigation bar.
///
/// The selected item wears a capsule that glides between slots, and its icon
/// swaps from outline to filled with a small bounce — the two cues together
/// make the current tab obvious without a hard selection colour.
class SoftNavigationBar extends StatelessWidget {
  const SoftNavigationBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest.withValues(alpha: 0.96),
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(26),
              ),
              child: SizedBox(
                height: 66,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot = constraints.maxWidth / items.length;
                    return Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: const Duration(milliseconds: 340),
                          curve: Curves.easeOutCubic,
                          start: slot * index + 8,
                          top: 8,
                          bottom: 8,
                          width: slot - 16,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Expanded(
                                child: _NavSlot(
                                  item: items[i],
                                  selected: i == index,
                                  onTap: () => onChanged(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colour = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Tooltip(
      message: item.label,
      preferBelow: false,
      // A long press names the tab, the way a desktop app names a toolbar
      // button — worth having when the label is one small word.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: selected ? 24 : 22,
                color: colour,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: theme.textTheme.labelSmall!.copyWith(
                color: colour,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: selected ? 11.5 : 11,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
