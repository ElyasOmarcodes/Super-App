import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme.dart';
import 'motion.dart';

/// Small pill naming the source dictionary an entry came from.
class BookChip extends StatelessWidget {
  const BookChip({super.key, required this.book, this.dense = false});

  final Book book;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = bookColor(book.id, scheme);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 11,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        book.name,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: QamusTheme.font,
          fontSize: dense ? 10.5 : 12,
          height: 1.5,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// Row of coloured dots standing in for the books a headword appears in.
class BookDots extends StatelessWidget {
  const BookDots({super.key, required this.bookIds});

  final List<int> bookIds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in bookIds)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: bookColor(id, scheme),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// A section heading with a hairline rule, used throughout the app.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.trailing,
    this.icon,
    this.tint,
  });

  final String title;
  final Widget? trailing;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = tint ?? theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 24, 2, 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: colour),
            ),
            const SizedBox(width: 9),
          ],
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Tappable word pill used for derivations, similar words and favourites.
class WordPill extends StatelessWidget {
  const WordPill({
    super.key,
    required this.word,
    required this.onTap,
    this.subtitle,
    this.emphasised = false,
    this.tint,
  });

  final String word;
  final String? subtitle;
  final bool emphasised;
  final Color? tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colour = tint ?? scheme.primary;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: emphasised
              ? colour.withValues(alpha: 0.12)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: emphasised
                ? colour.withValues(alpha: 0.38)
                : scheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              // Arabic content, pinned RTL even when the interface is English.
              textDirection: TextDirection.rtl,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                color: emphasised ? colour : scheme.onSurface,
              ),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Centred illustration + message for empty results and blank states.
class EmptyNote extends StatelessWidget {
  const EmptyNote({
    super.key,
    required this.icon,
    required this.title,
    this.detail,
    this.action,
    this.tint,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = tint ?? theme.colorScheme.primary;
    return Center(
      child: FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: colour.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: colour.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}
