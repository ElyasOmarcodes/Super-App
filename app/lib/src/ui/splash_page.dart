import 'package:flutter/material.dart';

import '../data/bootstrap.dart';
import '../developer.dart';
import '../l10n/locales.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'widgets/app_mark.dart';
import 'widgets/motion.dart';

/// The first thing anyone sees: the mark, the name, the author and the build.
///
/// It doubles as the first-launch progress screen. The bootstrap only reports
/// stages while it is actually unpacking, so on every later launch the bar and
/// the stage label simply never appear and the screen stays a splash.
///
/// This runs before the reader has chosen a language, so it speaks Arabic —
/// the default — and says as little as it can.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.progress,
    required this.onRetry,
    this.error,
  });

  final Stream<BootstrapProgress> progress;
  final VoidCallback onRetry;
  final Object? error;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// One controller drives the whole entrance; each element reads its own
  /// slice of it, so the mark, the name and the footer arrive in sequence
  /// without four separate tickers.
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _in.value = 1;
    } else {
      _in.forward();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  /// A fade-and-lift over [start]…[end] of the shared timeline.
  Widget _phase(double start, double end, Widget child, {double lift = 18}) {
    final curve = CurvedAnimation(
      parent: _in,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, inner) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, lift * (1 - curve.value)),
          child: inner,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const strings = Strings(AppLocale.ar);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: widget.error != null
                    ? _Failure(
                        error: widget.error!,
                        onRetry: widget.onRetry,
                        strings: strings,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          _phase(0, 0.45, _Mark(controller: _in), lift: 26),
                          const SizedBox(height: 32),
                          _phase(
                            0.22,
                            0.62,
                            Text(
                              strings.appName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displayMedium,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _phase(
                            0.30,
                            0.70,
                            Text(
                              strings.tagline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _Progress(progress: widget.progress),
                          const Spacer(),
                          _phase(
                            0.55,
                            1.0,
                            _Footer(name: Developer.name),
                            lift: 14,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The launcher mark, settling into place inside a turning progress ring.
///
/// The same ring Google Play draws while an app installs: Material's
/// indeterminate arc, stretching and contracting as it goes round.
class _Mark extends StatelessWidget {
  const _Mark({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final settle = CurvedAnimation(
      parent: controller,
      // easeOutCubic rather than easeOutBack: no overshoot, so the mark
      // settles instead of bouncing.
      curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: settle,
      builder: (context, child) =>
          Transform.scale(scale: 0.90 + 0.10 * settle.value, child: child),
      child: const AppMark(size: 148, progress: true),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress});

  final Stream<BootstrapProgress> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const strings = Strings(AppLocale.ar);

    return StreamBuilder<BootstrapProgress>(
      stream: progress,
      builder: (context, snapshot) {
        final value = snapshot.data;
        // Nothing to unpack means nothing to show: a returning reader sees a
        // clean splash rather than a bar that flashes and vanishes.
        if (value == null ||
            value.stage == BootstrapStage.idle ||
            value.stage == BootstrapStage.ready) {
          return const SizedBox(height: 58);
        }
        final title = switch (value.stage) {
          BootstrapStage.unpacking => strings.unpacking,
          BootstrapStage.writing => strings.writingDb,
          BootstrapStage.indexing => strings.indexing,
          BootstrapStage.failed => strings.setupFailed,
          _ => strings.preparing,
        };
        return SizedBox(
          height: 58,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value.fraction < 0 ? null : value.fraction,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  title,
                  key: ValueKey(title),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(strings.onceOnly, style: theme.textTheme.labelSmall),
            ],
          ),
        );
      },
    );
  }
}

/// The author's line, then the toolkit and the build, hairline-separated.
class _Footer extends StatelessWidget {
  const _Footer({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        children: [
          Text(
            name,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 0.2,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Always left to right: "By Flutter 1.1.0" is a signature, not a
              // sentence, and reads the same in every interface language.
              Text(
                'By Flutter',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: QamusTheme.cyan,
                ),
              ),
              Container(
                width: 1,
                height: 11,
                margin: const EdgeInsets.symmetric(horizontal: 9),
                color: scheme.outlineVariant,
              ),
              Text(
                'v$kAppVersion',
                textDirection: TextDirection.ltr,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({
    required this.error,
    required this.onRetry,
    required this.strings,
  });

  final Object error;
  final VoidCallback onRetry;
  final Strings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_rounded, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: 20),
        Text(strings.setupFailed, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          '$error',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(strings.retry),
        ),
      ],
    );
  }
}
