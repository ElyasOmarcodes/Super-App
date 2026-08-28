import 'package:flutter/material.dart';

import '../data/bootstrap.dart';
import '../l10n/locales.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'widgets/motion.dart';

/// Shown once, on the very first launch, while the shipped archive is unpacked
/// and the search indexes are built on the device.
///
/// This runs before the reader has picked a language, so it speaks Arabic —
/// the default — and says as little as possible.
class SetupPage extends StatelessWidget {
  const SetupPage({
    super.key,
    required this.progress,
    required this.onRetry,
    this.error,
  });

  final Stream<BootstrapProgress> progress;
  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const strings = Strings(AppLocale.ar);

    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: error != null
                  ? _Failure(error: error!, onRetry: onRetry, strings: strings)
                  : StreamBuilder<BootstrapProgress>(
                      stream: progress,
                      builder: (context, snapshot) {
                        final value =
                            snapshot.data ??
                            const BootstrapProgress(BootstrapStage.idle, -1);
                        final title = switch (value.stage) {
                          BootstrapStage.unpacking => strings.unpacking,
                          BootstrapStage.writing => strings.writingDb,
                          BootstrapStage.indexing => strings.indexing,
                          BootstrapStage.ready => strings.ready,
                          BootstrapStage.failed => strings.setupFailed,
                          BootstrapStage.idle => strings.preparing,
                        };
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Rosette(
                              size: 124,
                              child: Text(
                                'ق',
                                style: TextStyle(
                                  fontFamily: QamusTheme.font,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 34),
                            Text(
                              strings.appName,
                              style: theme.textTheme.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.tagline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 42),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value.fraction < 0
                                    ? null
                                    : value.fraction,
                                minHeight: 6,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              child: Text(
                                title,
                                key: ValueKey(title),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.onceOnly,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
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
