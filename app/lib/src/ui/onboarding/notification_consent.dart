import 'package:flutter/material.dart';

import '../../app.dart';
import '../../theme.dart';
import '../widgets/cards.dart';
import '../widgets/motion.dart';

/// The last page of the first launch: may we send you a word each morning?
///
/// The system's own dialog is never the first thing the reader sees. This page
/// explains what would arrive and what it costs — nothing — and only then, on
/// a deliberate tap, hands over to the platform. A refusal here is silent and
/// final until the reader turns the switch on in the settings.
class NotificationConsentPage extends StatefulWidget {
  const NotificationConsentPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<NotificationConsentPage> createState() =>
      _NotificationConsentPageState();
}

class _NotificationConsentPageState extends State<NotificationConsentPage> {
  bool _busy = false;

  Future<void> _ask() async {
    if (_busy) return;
    setState(() => _busy = true);
    final scope = context.qamus;

    // The platform decides; whichever way it answers, the reader moves on.
    final granted = await scope.notifications.requestPermission();
    await scope.settings.setDailyWord(granted);
    if (granted) {
      await scope.notifications.reschedule(
        dictionary: scope.dictionary,
        settings: scope.settings,
      );
    }
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;
    final scope = context.qamus;
    final word = scope.dictionary.wordOfDay(DateTime.now());

    return Scaffold(
      body: AuroraBackground(
        colors: const [QamusTheme.cyan, QamusTheme.violet],
        child: SafeArea(
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
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeSlideIn(
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: QamusTheme.gradient(QamusTheme.cyan),
                                boxShadow: [
                                  BoxShadow(
                                    color: QamusTheme.cyan.withValues(
                                      alpha: 0.38,
                                    ),
                                    blurRadius: 26,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 110),
                            child: Text(
                              strings.dailyWordAsk,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 180),
                            child: Text(
                              strings.dailyWordAskDetail,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.95,
                              ),
                            ),
                          ),

                          // A worked sample of the very thing being offered,
                          // built from today's real word.
                          if (word != null) ...[
                            const SizedBox(height: 26),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 250),
                              child: _SampleToast(
                                word: word.word,
                                preview: word.preview,
                                appName: strings.appName,
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 330),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _ask,
                                icon: const Icon(
                                  Icons.notifications_active_rounded,
                                ),
                                label: Text(
                                  strings.allowNotifications,
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
                          const SizedBox(height: 8),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 380),
                            child: TextButton(
                              onPressed: _busy ? null : widget.onDone,
                              child: Text(strings.notNow),
                            ),
                          ),
                        ],
                      ),
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
}

/// A mock of the notification itself, so the reader is agreeing to something
/// they have already seen rather than to a word.
class _SampleToast extends StatelessWidget {
  const _SampleToast({
    required this.word,
    required this.preview,
    required this.appName,
  });

  final String word;
  final String preview;
  final String appName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: QamusTheme.gradient(QamusTheme.violet),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'ق',
                style: TextStyle(
                  fontFamily: QamusTheme.font,
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  word,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  preview,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
