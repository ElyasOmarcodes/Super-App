import 'package:flutter/material.dart';

import '../app.dart';
import '../developer.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'widgets/cards.dart';
import 'widgets/motion.dart';

/// The privacy policy, in all four languages.
///
/// Google Play requires one before it will accept a listing. It is short here
/// because there is genuinely little to say: nothing leaves the device.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  /// Kept in step with `docs/privacy-policy.md`, which is what gets hosted for
  /// the store listing — the two must not drift.
  static const lastUpdated = '2026-08-29';

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final sections = <(IconData, Color, String, String)>[
      (
        Icons.block_rounded,
        QamusTheme.emerald,
        strings.privacyHeading1,
        strings.privacyBody1,
      ),
      (
        Icons.phone_android_rounded,
        QamusTheme.blue,
        strings.privacyHeading2,
        strings.privacyBody2,
      ),
      (
        Icons.verified_user_rounded,
        QamusTheme.violet,
        strings.privacyHeading3,
        strings.privacyBody3,
      ),
      (
        Icons.wifi_off_rounded,
        QamusTheme.cyan,
        strings.privacyHeading4,
        strings.privacyBody4,
      ),
      (
        Icons.menu_book_rounded,
        QamusTheme.amber,
        strings.privacyHeading5,
        strings.privacyBody5,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.privacy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 48),
        children: [
          FadeSlideIn(
            child: ColourCard(
              accent: QamusTheme.emerald,
              watermark: Icons.shield_rounded,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.privacy,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.privacyDetail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${strings.privacyUpdated}: $lastUpdated',
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < sections.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 60 * (i + 1)),
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(
                            icon: sections[i].$1,
                            colour: sections[i].$2,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sections[i].$3,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sections[i].$4,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.5,
                          height: 1.95,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delay: const Duration(milliseconds: 420),
            child: Column(
              children: [
                Text(
                  strings.privacyContact,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  Developer.email,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The same policy as plain text, for `docs/privacy-policy.md` and for anyone
/// who needs to paste it into a store listing.
String privacyPolicyAsText(Strings strings) {
  final buffer = StringBuffer()
    ..writeln(strings.privacy)
    ..writeln('${strings.privacyUpdated}: ${PrivacyPage.lastUpdated}')
    ..writeln();
  for (final (heading, body) in [
    (strings.privacyHeading1, strings.privacyBody1),
    (strings.privacyHeading2, strings.privacyBody2),
    (strings.privacyHeading3, strings.privacyBody3),
    (strings.privacyHeading4, strings.privacyBody4),
    (strings.privacyHeading5, strings.privacyBody5),
  ]) {
    buffer
      ..writeln(heading)
      ..writeln(body)
      ..writeln();
  }
  buffer
    ..writeln(strings.privacyContact)
    ..writeln(Developer.email);
  return buffer.toString();
}
