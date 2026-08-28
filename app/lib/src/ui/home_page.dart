import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/arabic.dart';
import '../data/models.dart';
import '../theme.dart';
import 'books_sheet.dart';
import 'dashboard.dart';
import 'deep_search_page.dart';
import 'widgets/cards.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

export 'dashboard.dart' show decodeRecord;

/// The search surface, and the dashboard the reader lands on before typing.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onOpenMenu});

  /// Opens the shell's drawer. Null when the page is shown on its own, as in
  /// a widget test, in which case the menu button is simply absent.
  final VoidCallback? onOpenMenu;

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
    final scope = context.qamus;
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

  void _openEntry(String key) => openEntry(context, key);

  void _setMode(SearchMode mode) {
    context.qamus.settings.setSearchMode(mode);
    if (_controller.text.isNotEmpty) _run(_controller.text);
  }

  String _modeLabel(SearchMode mode) => switch (mode) {
    SearchMode.starts => context.str.modeStarts,
    SearchMode.ends => context.str.modeEnds,
    SearchMode.contains => context.str.modeContains,
    SearchMode.exact => context.str.modeExact,
    SearchMode.root => context.str.modeRoot,
  };

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final settings = scope.settings;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              controller: _controller,
              focus: _focus,
              onOpenMenu: widget.onOpenMenu,
              title: strings.appName,
              hint: strings.searchHint,
              clearLabel: strings.clear,
              onChanged: _onQueryChanged,
              onSubmitted: _run,
              onClear: () {
                _controller.clear();
                _run('');
              },
            ),
            _ModeBar(
              mode: settings.searchMode,
              labelOf: _modeLabel,
              onModeChanged: _setMode,
              bookLabel: _bookLabel(scope),
              booksFiltered: !settings.allBooksSelected,
              onBooks: () => showBooksSheet(context),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _query.isEmpty
                    ? Dashboard(
                        key: const ValueKey('dashboard'),
                        onOpen: _openEntry,
                        onSearch: (word) {
                          _controller.text = word;
                          _run(word);
                        },
                      )
                    : _Results(
                        key: ValueKey(_query),
                        results: _results,
                        searching: _searching,
                        query: _query,
                        mode: settings.searchMode,
                        modeLabel: _modeLabel(settings.searchMode),
                        onOpen: _openEntry,
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _query.isEmpty ? const Offset(0, 2.4) : Offset.zero,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 82),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DeepSearchPage(initialQuery: _controller.text),
              ),
            ),
            backgroundColor: QamusTheme.emerald,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.travel_explore_rounded),
            label: Text(strings.deepSearch),
          ),
        ),
      ),
    );
  }
}

/// One selected book reads best as its own name; anything else as a count.
String _bookLabel(Qamus scope) {
  final selected = scope.settings.selectedBooks;
  if (scope.settings.allBooksSelected) return scope.strings.allBooks;
  if (selected.length == 1) {
    return scope.dictionary.book(selected.first)?.name ??
        scope.strings.books(1);
  }
  return scope.strings.books(selected.length);
}

// ---------------------------------------------------------------- the header

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.focus,
    required this.onOpenMenu,
    required this.title,
    required this.hint,
    required this.clearLabel,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback? onOpenMenu;
  final String title;
  final String hint;
  final String clearLabel;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (onOpenMenu != null) ...[
                Pressable(
                  onTap: onOpenMenu,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 21,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: QamusTheme.shadow(scheme, strength: 0.6),
              ),
              child: TextField(
                controller: controller,
                focusNode: focus,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: theme.textTheme.headlineSmall,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
                  suffixIcon: AnimatedScale(
                    scale: value.text.isEmpty ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      tooltip: clearLabel,
                      icon: const Icon(Icons.cancel_rounded),
                      onPressed: onClear,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
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
    required this.labelOf,
    required this.onModeChanged,
    required this.bookLabel,
    required this.booksFiltered,
    required this.onBooks,
  });

  final SearchMode mode;
  final String Function(SearchMode) labelOf;
  final ValueChanged<SearchMode> onModeChanged;
  final String bookLabel;
  final bool booksFiltered;
  final VoidCallback onBooks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          Center(
            child: Pressable(
              onTap: onBooks,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: booksFiltered
                      ? QamusTheme.violet.withValues(alpha: 0.13)
                      : scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: booksFiltered
                        ? QamusTheme.violet.withValues(alpha: 0.4)
                        : scheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      booksFiltered
                          ? Icons.filter_alt_rounded
                          : Icons.library_books_rounded,
                      size: 16,
                      color: booksFiltered
                          ? QamusTheme.violet
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      bookLabel,
                      textDirection: booksFiltered ? TextDirection.rtl : null,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: booksFiltered
                            ? QamusTheme.violet
                            : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
            child: VerticalDivider(width: 1, color: scheme.outlineVariant),
          ),
          for (final option in SearchMode.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Center(
                child: _ModePill(
                  label: labelOf(option),
                  selected: option == mode,
                  onTap: () => onModeChanged(option),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? QamusTheme.gradient(QamusTheme.violet) : null,
          color: selected ? null : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : scheme.outlineVariant,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: QamusTheme.violet.withValues(alpha: 0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- results

class _Results extends StatelessWidget {
  const _Results({
    super.key,
    required this.results,
    required this.searching,
    required this.query,
    required this.mode,
    required this.modeLabel,
    required this.onOpen,
  });

  final List<Headword> results;
  final bool searching;
  final String query;
  final SearchMode mode;
  final String modeLabel;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;

    if (results.isEmpty) {
      return EmptyNote(
        icon: searching
            ? Icons.hourglass_top_rounded
            : Icons.search_off_rounded,
        title: searching ? strings.searchingLabel : strings.noResults,
        detail: searching ? null : strings.noResultsDetail,
      );
    }

    final scope = context.qamus;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 150),
      itemCount: results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
            child: Text(
              strings.resultHeader(results.length, modeLabel, query),
              style: theme.textTheme.titleSmall,
            ),
          );
        }
        final item = results[index - 1];
        final accent = bookColor(item.bookIds.first, theme.colorScheme);
        return FadeSlideIn(
          delay: Duration(milliseconds: 16 * (index - 1).clamp(0, 12)),
          offset: const Offset(0, 0.06),
          child: _ResultCard(
            item: item,
            query: query,
            mode: mode,
            accent: accent,
            onTap: () => onOpen(item.key),
            books: item.bookIds
                .map((id) => scope.dictionary.book(id)?.name ?? '')
                .where((n) => n.isNotEmpty)
                .toList(),
          ),
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.item,
    required this.query,
    required this.mode,
    required this.accent,
    required this.onTap,
    required this.books,
  });

  final Headword item;
  final String query;
  final SearchMode mode;
  final Color accent;
  final VoidCallback onTap;
  final List<String> books;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strings = context.str;

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Highlighted(
                  word: item.word,
                  entryKey: item.key,
                  query: query,
                  mode: mode,
                  style: theme.textTheme.headlineSmall!,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      strings.senses(item.senseCount),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(width: 8),
                    BookDots(bookIds: item.bookIds),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        books.join(' · '),
                        textDirection: TextDirection.rtl,
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
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

/// Picks out the part of the headword the query actually matched, which is
/// what makes an "ends with" search legible at a glance.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.word,
    required this.entryKey,
    required this.query,
    required this.mode,
    required this.style,
  });

  final String word;
  final String entryKey;
  final String query;
  final SearchMode mode;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final match = switch (mode) {
      SearchMode.starts => (0, query.length),
      SearchMode.ends => (entryKey.length - query.length, entryKey.length),
      SearchMode.contains => () {
        final at = entryKey.indexOf(query);
        return at < 0 ? (0, 0) : (at, at + query.length);
      }(),
      SearchMode.exact || SearchMode.root => (0, entryKey.length),
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

    // The corpus is Arabic whatever the interface language is, so its
    // direction is pinned rather than inherited from the page.
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      textDirection: TextDirection.rtl,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
