import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import 'entry_page.dart';
import 'home_page.dart' show decodeRecord;
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// Shared body for the two library tabs — saved words and reading history.
///
/// They differ only in their records, their accent colour and whether they
/// offer a "clear" action, so one widget serves both.
class LibraryView extends StatelessWidget {
  const LibraryView({
    super.key,
    required this.title,
    required this.icon,
    required this.tint,
    required this.records,
    required this.emptyTitle,
    required this.emptyDetail,
    this.onClear,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final List<String> records;
  final String emptyTitle;
  final String emptyDetail;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: tint, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.headlineSmall),
                        Text(
                          strings.words(records.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  if (onClear != null && records.isNotEmpty)
                    IconButton(
                      tooltip: strings.clearHistory,
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_sweep_rounded),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: records.isEmpty
                  ? EmptyNote(
                      icon: icon,
                      tint: tint,
                      title: emptyTitle,
                      detail: emptyDetail,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 150),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < records.length; i++)
                              Builder(
                                builder: (context) {
                                  final item = decodeRecord(records[i]);
                                  return FadeSlideIn(
                                    delay: Duration(
                                      milliseconds: 18 * i.clamp(0, 14),
                                    ),
                                    child: WordPill(
                                      word: item.word,
                                      emphasised: onClear == null,
                                      tint: tint,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              EntryPage(entryKey: item.key),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    return LibraryView(
      title: strings.navFavourites,
      icon: Icons.bookmark_rounded,
      tint: QamusTheme.rose,
      records: context.qamus.settings.favourites,
      emptyTitle: strings.noFavourites,
      emptyDetail: strings.noFavouritesDetail,
    );
  }
}

class RecentPage extends StatelessWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final settings = context.qamus.settings;
    return LibraryView(
      title: strings.navRecent,
      icon: Icons.history_rounded,
      tint: QamusTheme.blue,
      records: settings.history,
      emptyTitle: strings.noHistory,
      emptyDetail: strings.noHistoryDetail,
      onClear: settings.clearHistory,
    );
  }
}
