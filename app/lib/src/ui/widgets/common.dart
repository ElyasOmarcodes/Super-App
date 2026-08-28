import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme.dart';

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
        horizontal: dense ? 7 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        book.name,
        style: TextStyle(
          fontFamily: QamusTheme.ui,
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

/// A section heading with a hairline rule, used throughout the entry page.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.icon});

  final String title;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 26, 4, 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
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
  });

  final String word;
  final String? subtitle;
  final bool emphasised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: emphasised ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 19,
                  color: emphasised
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: theme.textTheme.labelSmall),
            ],
          ),
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
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 18),
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
    );
  }
}
