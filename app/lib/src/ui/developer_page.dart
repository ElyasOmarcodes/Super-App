import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../developer.dart';
import '../theme.dart';
import 'widgets/cards.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// Who wrote this, what they build, and three ways to reach them.
class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 70 * step++),
      child: child,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: const _Hero(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            sliver: SliverList.list(
              children: [
                stagger(
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Text(
                      strings.developerBio,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15.5,
                        height: 1.95,
                      ),
                    ),
                  ),
                ),

                // ------------------------------------------- what he builds
                stagger(
                  SectionTitle(
                    strings.platformsTitle,
                    icon: Icons.devices_rounded,
                    tint: QamusTheme.violet,
                  ),
                ),
                stagger(
                  const Row(
                    children: [
                      Expanded(
                        child: _Platform(
                          icon: Icons.android_rounded,
                          label: 'Android',
                          accent: QamusTheme.emerald,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Platform(
                          icon: Icons.phone_iphone_rounded,
                          label: 'iOS',
                          accent: QamusTheme.blue,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Platform(
                          icon: Icons.desktop_windows_rounded,
                          label: 'Windows',
                          accent: QamusTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                ),

                // -------------------------------------------- and he teaches
                stagger(
                  SectionTitle(
                    strings.teachesTitle,
                    icon: Icons.school_rounded,
                    tint: QamusTheme.amber,
                  ),
                ),
                stagger(
                  ColourCard(
                    accent: QamusTheme.amber,
                    watermark: Icons.school_rounded,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconBadge(
                          icon: Icons.menu_book_rounded,
                          colour: Colors.white,
                          onColour: true,
                          size: 38,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          strings.developerTeacher,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.developerRole,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ----------------------------------------------- reaching him
                stagger(
                  SectionTitle(
                    strings.contactTitle,
                    icon: Icons.connect_without_contact_rounded,
                    tint: QamusTheme.rose,
                  ),
                ),
                stagger(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      strings.contactDetail,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                stagger(
                  _ContactRow(
                    icon: Icons.chat_rounded,
                    accent: QamusTheme.emerald,
                    label: strings.whatsappLabel,
                    value: Developer.whatsappNumber,
                    target: Developer.whatsapp,
                  ),
                ),
                stagger(
                  _ContactRow(
                    icon: Icons.send_rounded,
                    accent: QamusTheme.blue,
                    label: strings.telegramLabel,
                    value: Developer.telegramHandle,
                    target: Developer.telegram,
                  ),
                ),
                stagger(
                  _ContactRow(
                    icon: Icons.alternate_email_rounded,
                    accent: QamusTheme.rose,
                    label: strings.emailLabel,
                    value: Developer.email,
                    target: Developer.mail,
                  ),
                ),

                const SizedBox(height: 28),
                stagger(
                  Center(
                    child: Text(
                      'By Flutter · v$kAppVersion',
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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

/// The portrait area: a drifting wash, a monogram, the name and the trade.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = context.str;

    return AuroraBackground(
      colors: const [QamusTheme.violet, QamusTheme.rose],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 46, 24, 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // The photograph, square and circular, ringed by a sweep of
              // all six of the app's accents — the same six that colour the
              // lexicons, so the portrait belongs to this app and no other.
              Container(
                width: 148,
                height: 148,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      QamusTheme.violet,
                      QamusTheme.blue,
                      QamusTheme.cyan,
                      QamusTheme.emerald,
                      QamusTheme.amber,
                      QamusTheme.rose,
                      QamusTheme.violet,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x597C5CFF),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                // A hairline of the page's own colour between ring and photo,
                // which is what makes the ring read as a stroke rather than
                // as a coloured edge of the picture.
                padding: const EdgeInsets.all(4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/img/developer.jpg',
                        fit: BoxFit.cover,
                        // A missing asset must never take the page down.
                        errorBuilder: (context, _, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: QamusTheme.gradient(QamusTheme.violet),
                          ),
                          child: const Center(
                            child: Text(
                              'EO',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontFamily: QamusTheme.font,
                                fontSize: 30,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Developer.name,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                Developer.nameLatin,
                textDirection: TextDirection.ltr,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  strings.developerRole,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      accent: accent,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, size: 30, color: accent),
          const SizedBox(height: 8),
          Text(
            label,
            textDirection: TextDirection.ltr,
            style: theme.textTheme.labelLarge?.copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// One way to reach him: tap opens the app, holding copies the address.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.target,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final Uri target;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.str;
    var opened = false;
    try {
      opened = await launchUrl(target, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (opened) return;
    // No WhatsApp, no mail client, no browser: the address is still useful,
    // so hand it over rather than failing silently.
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(strings.couldNotOpen)));
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.str.copiedToClipboard)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tooltip(
        message: '$label — $value',
        child: GestureDetector(
          onLongPress: () => _copy(context),
          child: SurfaceCard(
            onTap: () => _open(context),
            accent: accent,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 6, 12),
            child: Row(
              children: [
                IconBadge(icon: icon, colour: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleMedium),
                      Text(
                        value,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: strings.copyLabel,
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy_rounded, size: 19),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
