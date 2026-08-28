import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/arabic.dart';
import '../data/models.dart';
import '../theme.dart';
import 'books_sheet.dart';
import 'format.dart';
import 'deep_search_page.dart';
import 'entry_page.dart';
import 'roots_page.dart';
import 'saved_page.dart';
import 'settings_page.dart';
import 'widgets/common.dart';

/// The search surface: a query field, the mode selector, the book filter and
/// live results — everything one screen away.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  List<Headword> _results = const [];
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Debounced so that a fast typist triggers one query, not eight.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 110), () => _run(value));
  }

  void _run(String value) {
    final scope = Qamus.of(context);
    final key = normalize(value);
    if (key.isEmpty) {
      setState(() {
        _results = const [];
        _query = '';
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final hits = scope.dictionary.search(
      value,
      mode: scope.settings.searchMode,
      books: scope.settings.selectedBooks,
      limit: 120,
    );
    if (!mounted) return;
    setState(() {
      _results = hits;
      _query = key;
      _searching = false;
    });
  }

  void _openEntry(String key) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => EntryPage(entryKey: key)));
  }

  void _setMode(SearchMode mode) {
    Qamus.of(context).settings.setSearchMode(mode);
    if (_controller.text.isNotEmpty) _run(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final scope = Qamus.of(context);
    final theme = Theme.of(context);
    final settings = scope.settings;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              controller: _controller,
              focus: _focus,
              onChanged: _onQueryChanged,
              onSubmitted: _run,
              onClear: () {
                _controller.clear();
                _run('');
              },
            ),
            _ModeBar(
              mode: settings.searchMode,
              onModeChanged: _setMode,
              bookLabel: _bookLabel(scope),
              booksFiltered: !settings.allBooksSelected,
              onBooks: () => showBooksSheet(context),
            ),
            const Divider(height: 1),
            Expanded(
              child: _query.isEmpty
                  ? _Landing(
                      onOpen: _openEntry,
                      onSearch: (word) {
                        _controller.text = word;
                        _run(word);
                      },
                    )
                  : _Results(
                      results: _results,
                      searching: _searching,
                      query: _query,
                      mode: settings.searchMode,
                      onOpen: _openEntry,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _query.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      DeepSearchPage(initialQuery: _controller.text),
                ),
              ),
              icon: const Icon(Icons.travel_explore_rounded),
              label: Text('بحث في المعاني', style: theme.textTheme.labelLarge),
            ),
    );
  }
}

/// One selected book reads best as its own name; anything else as a count.
String _bookLabel(Qamus scope) {
  final selected = scope.settings.selectedBooks;
  if (scope.settings.allBooksSelected) return 'كل المعاجم';
  if (selected.length == 1) {
    return scope.dictionary.book(selected.first)?.name ?? countedBooks(1);
  }
  return countedBooks(selected.length);
}

// ---------------------------------------------------------------- the header

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('قاموس المعاني', style: theme.textTheme.headlineMedium),
              const Spacer(),
              IconButton(
                tooltip: 'المحفوظات',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SavedPage()),
                ),
                icon: const Icon(Icons.bookmarks_outlined),
              ),
              IconButton(
                tooltip: 'الإعدادات',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
                ),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => TextField(
              controller: controller,
              focusNode: focus,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: onClear,
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- the mode bar

class _ModeBar extends StatelessWidget {
  const _ModeBar({
    required this.mode,
    required this.onModeChanged,
    required this.bookLabel,
    required this.booksFiltered,
    required this.onBooks,
  });

  final SearchMode mode;
  final ValueChanged<SearchMode> onModeChanged;
  final String bookLabel;
  final bool booksFiltered;
  final VoidCallback onBooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ActionChip(
            avatar: Icon(
              booksFiltered
                  ? Icons.filter_alt_rounded
                  : Icons.library_books_outlined,
              size: 17,
              color: booksFiltered ? theme.colorScheme.primary : null,
            ),
            label: Text(bookLabel),
            onPressed: onBooks,
            backgroundColor: booksFiltered
                ? theme.colorScheme.primaryContainer
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: VerticalDivider(
              width: 1,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          for (final option in SearchMode.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(option.label),
                selected: option == mode,
                onSelected: (_) => onModeChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- results

class _Results extends StatelessWidget {
  const _Results({
    required this.results,
    required this.searching,
    required this.query,
    required this.mode,
    required this.onOpen,
  });

  final List<Headword> results;
  final bool searching;
  final String query;
  final SearchMode mode;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (results.isEmpty) {
      return EmptyNote(
        icon: searching
            ? Icons.hourglass_empty_rounded
            : Icons.search_off_rounded,
        title: searching ? 'جارٍ البحث…' : 'لا توجد نتائج',
        detail: searching
            ? null
            : 'جرّب نمط بحث آخر، أو وسّع نطاق المعاجم المحدّدة',
      );
    }

    final scope = Qamus.of(context);
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Text(
              '${countedEntries(results.length)} · ${mode.label} «$query»',
              style: theme.textTheme.titleSmall,
            ),
          );
        }
        final item = results[index - 1];
        return _ResultTile(
          item: item,
          query: query,
          mode: mode,
          onTap: () => onOpen(item.key),
          books: item.bookIds
              .map((id) => scope.dictionary.book(id)?.name ?? '')
              .where((n) => n.isNotEmpty)
              .toList(),
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.item,
    required this.query,
    required this.mode,
    required this.onTap,
    required this.books,
  });

  final Headword item;
  final String query;
  final SearchMode mode;
  final VoidCallback onTap;
  final List<String> books;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Highlighted(
                    word: item.word,
                    key_: item.key,
                    query: query,
                    mode: mode,
                    style: theme.textTheme.headlineSmall!,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        countedSenses(item.senseCount),
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      BookDots(bookIds: item.bookIds),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          books.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: theme.colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Underlines the part of the headword the query actually matched, which is
/// what makes an "ends with" search legible at a glance.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.word,
    required this.key_,
    required this.query,
    required this.mode,
    required this.style,
  });

  final String word;
  final String key_;
  final String query;
  final SearchMode mode;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final match = switch (mode) {
      SearchMode.starts => (0, query.length),
      SearchMode.ends => (key_.length - query.length, key_.length),
      SearchMode.contains => () {
        final at = key_.indexOf(query);
        return at < 0 ? (0, 0) : (at, at + query.length);
      }(),
      SearchMode.exact || SearchMode.root => (0, key_.length),
    };

    // The display word carries diacritics the key does not, so walk both in
    // step to find where the matched key range lands in the visible text.
    final spans = <TextSpan>[];
    var keyIndex = 0;
    final buffer = StringBuffer();
    var inMatch = false;

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: inMatch
              ? TextStyle(color: accent, fontWeight: FontWeight.w700)
              : null,
        ),
      );
      buffer.clear();
    }

    for (final ch in word.split('')) {
      final contributes = normalize(ch).isNotEmpty;
      final nowInMatch =
          contributes && keyIndex >= match.$1 && keyIndex < match.$2;
      if (nowInMatch != inMatch) {
        flush();
        inMatch = nowInMatch;
      }
      buffer.write(ch);
      if (contributes) keyIndex++;
    }
    flush();

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// --------------------------------------------------------------- the landing

class _Landing extends StatelessWidget {
  const _Landing({required this.onOpen, required this.onSearch});

  final ValueChanged<String> onOpen;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final scope = Qamus.of(context);
    final settings = scope.settings;
    final theme = Theme.of(context);
    final history = settings.history;
    final favourites = settings.favourites;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        _Stats(
          entries: scope.dictionary.entryCount,
          roots: scope.dictionary.rootCount,
          books: scope.dictionary.books.length,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Tile(
                icon: Icons.account_tree_outlined,
                title: 'تصفّح الجذور',
                detail: 'ادخل إلى المعجم من جذوره',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RootsPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Tile(
                icon: Icons.travel_explore_rounded,
                title: 'بحث في المعاني',
                detail: 'فتّش داخل نصّ الشروح كلّها',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DeepSearchPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (favourites.isNotEmpty) ...[
          const SectionTitle('المحفوظة', icon: Icons.bookmark_outline_rounded),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final record in favourites.take(14))
                Builder(
                  builder: (context) {
                    final item = decodeRecord(record);
                    return WordPill(
                      word: item.word,
                      onTap: () => onOpen(item.key),
                      emphasised: true,
                    );
                  },
                ),
            ],
          ),
        ],
        if (history.isNotEmpty) ...[
          SectionTitle(
            'آخر ما بحثت عنه',
            icon: Icons.history_rounded,
            trailing: TextButton(
              onPressed: settings.clearHistory,
              child: const Text('مسح'),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final record in history.take(18))
                Builder(
                  builder: (context) {
                    final item = decodeRecord(record);
                    return WordPill(
                      word: item.word,
                      onTap: () => onOpen(item.key),
                    );
                  },
                ),
            ],
          ),
        ],
        const SectionTitle('من كنوز اللغة', icon: Icons.auto_awesome_outlined),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final word in _sampler)
              WordPill(word: word, onTap: () => onSearch(word)),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'نمط «ينتهي بـ» يجد القوافي والأوزان: اكتب «يب» لترى كل ما ينتهي بها.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

const _sampler = [
  'سَلْسَبِيل',
  'غَيْهَب',
  'أُفُق',
  'إِزْمِيل',
  'رَصِين',
  'تَبَتُّل',
  'خَنْدَرِيس',
  'يَنْبُوع',
  'أَصِيل',
  'دَيْجُور',
];

({String key, String word}) decodeRecord(String record) {
  final at = record.indexOf(' ');
  if (at < 0) return (key: record, word: record);
  return (key: record.substring(0, at), word: record.substring(at + 1));
}

class _Stats extends StatelessWidget {
  const _Stats({
    required this.entries,
    required this.roots,
    required this.books,
  });

  final int entries;
  final int roots;
  final int books;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget cell(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 24,
            ),
          ),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.07),
            QamusTheme.gold.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          cell(arabicNumber(entries), 'مدخلًا'),
          cell(arabicNumber(roots), 'جذرًا'),
          cell(arabicNumber(books), 'معجمًا'),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(detail, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
