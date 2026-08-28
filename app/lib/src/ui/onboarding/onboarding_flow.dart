import 'package:flutter/material.dart';

import '../../app.dart';
import '../../l10n/locales.dart';
import '../../l10n/strings.dart';
import '../../theme.dart';
import '../shell.dart';
import '../widgets/motion.dart';
import 'intro_pages.dart';

/// First launch: pick a language, then read the three intro cards.
///
/// Both stages live in one widget so the language choice can take effect
/// immediately — the intro pages are already in the chosen language by the
/// time they slide in.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late bool _showIntro = Qamus.of(context).settings.chosenLocale != null;

  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    await Qamus.of(context).settings.setOnboarded(true);
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _showIntro
          ? IntroPages(key: const ValueKey('intro'), onDone: _finish)
          : _LanguagePage(
              key: const ValueKey('language'),
              onChosen: () => setState(() => _showIntro = true),
            ),
    );
  }
}

class _LanguagePage extends StatefulWidget {
  const _LanguagePage({super.key, required this.onChosen});

  final VoidCallback onChosen;

  @override
  State<_LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<_LanguagePage> {
  AppLocale? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = Qamus.of(context);
    // Before a choice is made, label the screen in the language being
    // considered — so the heading changes as the reader taps around.
    final choice = _selected ?? scope.locale;
    final strings = Strings(choice);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          // Scrollable rather than centred-and-fixed: four language cards plus
          // the mark do not fit a short screen in landscape.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 26,
                      ),
                      child: _content(theme, scope, strings, choice),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    ThemeData theme,
    Qamus scope,
    Strings strings,
    AppLocale choice,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FadeSlideIn(
          child: Rosette(
            size: 104,
            child: Text(
              'ق',
              style: TextStyle(
                fontFamily: QamusTheme.font,
                fontSize: 42,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: Directionality(
            textDirection: choice.textDirection,
            child: Column(
              children: [
                Text(
                  strings.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  strings.chooseLanguageDetail,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        for (var i = 0; i < AppLocale.values.length; i++)
          FadeSlideIn(
            delay: Duration(milliseconds: 200 + i * 70),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LanguageTile(
                locale: AppLocale.values[i],
                selected: _selected == AppLocale.values[i],
                onTap: () => setState(() => _selected = AppLocale.values[i]),
              ),
            ),
          ),
        const SizedBox(height: 18),
        FadeSlideIn(
          delay: const Duration(milliseconds: 500),
          child: AnimatedOpacity(
            opacity: _selected == null ? 0.45 : 1,
            duration: const Duration(milliseconds: 220),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _selected == null
                    ? null
                    : () async {
                        await scope.settings.setLocale(_selected!);
                        widget.onChosen();
                      },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  strings.continueLabel,
                  style: theme.textTheme.labelLarge,
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
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

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.8 : 1,
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
                    ),
                    if (locale.englishName != locale.nativeName)
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
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.check_circle_rounded,
                color: scheme.primary,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
