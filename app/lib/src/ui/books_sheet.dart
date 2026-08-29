import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import 'widgets/motion.dart';

/// Lets the reader restrict every search to a chosen set of source books —
/// the whole shelf, one معجم, or any combination.
Future<void> showBooksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _BooksSheet(),
  );
}

class _BooksSheet extends StatelessWidget {
  const _BooksSheet();

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final settings = scope.settings;
    final theme = Theme.of(context);
    final selected = settings.selectedBooks;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(strings.lexicons, style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: settings.allBooksSelected
                      ? null
                      : settings.selectAllBooks,
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: Text(strings.selectAll),
                ),
              ],
            ),
            Text(strings.lexiconsDetail, style: theme.textTheme.bodySmall),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: scope.dictionary.books.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final book = scope.dictionary.books[index];
                  final on = selected.contains(book.id);
                  final color = bookColor(book.id, theme.colorScheme);
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 30 * index),
                    child: Pressable(
                      onTap: () => settings.toggleBook(book.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: on
                              ? color.withValues(alpha: 0.10)
                              : theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: on
                                ? color.withValues(alpha: 0.55)
                                : theme.colorScheme.outlineVariant,
                            width: on ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 10,
                              height: on ? 40 : 26,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: on ? 1 : 0.28),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 16),
                                  ),
                                  Text(
                                    '${strings.entries(book.count)} · '
                                    '${book.isThesaurus ? strings.thesaurus : strings.definitions}',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: on,
                              onChanged: (_) => settings.toggleBook(book.id),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
