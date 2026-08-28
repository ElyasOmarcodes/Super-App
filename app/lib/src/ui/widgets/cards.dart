import 'package:flutter/material.dart';

import '../../theme.dart';
import 'motion.dart';

/// A card that carries its own colour: a full accent gradient, white text and
/// a soft shadow in the accent's own hue.
///
/// These are what make the dashboard read as a dashboard rather than a list.
class ColourCard extends StatelessWidget {
  const ColourCard({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.height,
    this.watermark,
  });

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double? height;

  /// A big translucent glyph bled off the trailing edge, for depth.
  final IconData? watermark;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: QamusTheme.gradient(accent),
          borderRadius: BorderRadius.circular(QamusTheme.radius),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (watermark != null)
              PositionedDirectional(
                end: -18,
                bottom: -22,
                child: Icon(
                  watermark,
                  size: 118,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// A plain raised card on the neutral ground: white by day, near-black by
/// night, with a hairline border and a soft shadow.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.accent,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// When set, the card wears a faint tint and border of this colour.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = accent;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: tint == null
              ? scheme.surfaceContainerLow
              : Color.alphaBlend(
                  tint.withValues(alpha: 0.07),
                  scheme.surfaceContainerLow,
                ),
          borderRadius: BorderRadius.circular(QamusTheme.radius),
          border: Border.all(
            color: tint == null
                ? scheme.outlineVariant
                : tint.withValues(alpha: 0.28),
          ),
          boxShadow: QamusTheme.shadow(scheme, strength: 0.7),
        ),
        child: child,
      ),
    );
  }
}

/// A rounded square holding an icon, tinted to match its card.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.colour,
    this.size = 42,
    this.onColour = false,
  });

  final IconData icon;
  final Color colour;
  final double size;

  /// True when the badge sits on a coloured card, where it goes translucent
  /// white instead of tinted.
  final bool onColour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onColour
            ? Colors.white.withValues(alpha: 0.22)
            : colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: onColour ? Colors.white : colour,
      ),
    );
  }
}

/// A thin capsule showing one value's share of a total.
class ShareBar extends StatelessWidget {
  const ShareBar({
    super.key,
    required this.fraction,
    required this.colour,
    this.height = 5,
  });

  final double fraction;
  final Color colour;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: scheme.outlineVariant),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.02, 1.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => Container(
                height: height,
                color: Color.lerp(colour.withValues(alpha: 0.3), colour, t),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
