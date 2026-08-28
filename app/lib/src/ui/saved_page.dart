import 'package:flutter/material.dart';

import '../app.dart';
import 'entry_page.dart';
import 'home_page.dart' show decodeRecord;
import 'widgets/common.dart';

/// Bookmarks and search history, side by side.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Qamus.of(context).settings;
    final favourites = settings.favourites;
    final history = settings.history;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحفوظات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المفضّلة'),
              Tab(text: 'السجلّ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WordList(
              records: favourites,
              empty: const EmptyNote(
                icon: Icons.bookmark_border_rounded,
                title: 'لا كلمات محفوظة بعد',
                detail: 'اضغط على أيقونة الحفظ في صفحة أي كلمة',
              ),
            ),
            _WordList(
              records: history,
              empty: const EmptyNote(
                icon: Icons.history_rounded,
                title: 'السجلّ فارغ',
              ),
              onClear: history.isEmpty ? null : settings.clearHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  const _WordList({required this.records, required this.empty, this.onClear});

  final List<String> records;
  final Widget empty;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return empty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        if (onClear != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('مسح السجلّ'),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final record in records)
              Builder(
                builder: (context) {
                  final item = decodeRecord(record);
                  return WordPill(
                    word: item.word,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EntryPage(entryKey: item.key),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
