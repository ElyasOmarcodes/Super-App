import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import 'format.dart';

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
    final scope = Qamus.of(context);
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
                Text('المعاجم', style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: settings.allBooksSelected
                      ? null
                      : settings.selectAllBooks,
                  child: const Text('تحديد الكل'),
                ),
              ],
            ),
            Text(
              'يقتصر البحث على المعاجم المحدّدة فقط',
              style: theme.textTheme.bodySmall,
            ),
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
                  return Material(
                    color: on
                        ? color.withValues(alpha: 0.10)
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => settings.toggleBook(book.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: on
                                ? color.withValues(alpha: 0.5)
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 34,
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
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontSize: 19),
                                  ),
                                  Text(
                                    '${arabicNumber(book.count)} ${countedEntries(book.count).split(' ').last} · '
                                    '${book.isThesaurus ? 'مرادفات وأضداد' : 'شروح ومعانٍ'}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: on,
                              onChanged: (_) => settings.toggleBook(book.id),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
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
