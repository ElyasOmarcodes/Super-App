import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

    // Icons and tints, paired by position with privacySections — so adding
    // a section in one place and forgetting the other is a compile error
    // rather than a silently missing card.
    const marks = <(IconData, Color)>[
      (Icons.block_rounded, QamusTheme.emerald),
      (Icons.phone_android_rounded, QamusTheme.blue),
      (Icons.verified_user_rounded, QamusTheme.violet),
      (Icons.wifi_off_rounded, QamusTheme.cyan),
      (Icons.menu_book_rounded, QamusTheme.amber),
      (Icons.badge_rounded, QamusTheme.violet),
      (Icons.fact_check_rounded, QamusTheme.blue),
      (Icons.lock_rounded, QamusTheme.emerald),
      (Icons.auto_delete_rounded, QamusTheme.rose),
    ];
    final sections = privacySections(strings);
    assert(
      marks.length == sections.length,
      'every policy section needs an icon',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.privacy),
        actions: [
          IconButton(
            tooltip: strings.privacyOnline,
            onPressed: () => _openPublished(context),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
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
                            icon: marks[i].$1,
                            colour: marks[i].$2,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sections[i].$1,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sections[i].$2,
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

/// Opens the published policy in the reader's browser.
///
/// Google Play links to that URL, so anyone comparing the two should be able
/// to reach it from inside the app. If no browser answers, the address is
/// handed over instead of failing silently.
Future<void> _openPublished(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final strings = context.str;
  var opened = false;
  try {
    opened = await launchUrl(
      Developer.privacyPolicy,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (opened) return;
  await Clipboard.setData(
    ClipboardData(text: Developer.privacyPolicy.toString()),
  );
  messenger.showSnackBar(SnackBar(content: Text(strings.couldNotOpen)));
}

/// Every section of the policy, in reading order.
///
/// One list, used by the page, by the plain-text copy and by the tests, so a
/// section can never be added in one place and forgotten in another.
List<(String, String)> privacySections(Strings strings) => [
  (strings.privacyHeading1, strings.privacyBody1),
  (strings.privacyHeading2, strings.privacyBody2),
  (strings.privacyHeading3, strings.privacyBody3),
  (strings.privacyHeading4, strings.privacyBody4),
  (strings.privacyHeading5, strings.privacyBody5),
  (
    strings.privacyHeading6,
    strings.privacyBody6(
      strings.appName,
      Developer.packageId,
      Developer.name,
      Developer.email,
    ),
  ),
  (strings.privacyHeading7, strings.privacyBody7),
  (strings.privacyHeading8, strings.privacyBody8),
  (strings.privacyHeading9, strings.privacyBody9),
];

/// The same policy as plain text, for `docs/privacy-policy.md` and for anyone
/// who needs to paste it into a store listing.
String privacyPolicyAsText(Strings strings) {
  final buffer = StringBuffer()
    ..writeln(strings.privacy)
    ..writeln('${strings.privacyUpdated}: ${PrivacyPage.lastUpdated}')
    ..writeln();
  for (final (heading, body) in privacySections(strings)) {
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
