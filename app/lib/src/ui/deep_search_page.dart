import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/arabic.dart';
import '../data/dictionary.dart';
import '../data/models.dart';
import 'books_sheet.dart';
import 'format.dart';
import 'entry_page.dart';
import 'widgets/common.dart';

/// Full-text search *inside* the definitions.
///
/// Unlike headword search there is no index to lean on — the sweep inflates
/// all 51 MB of packed text — so it runs in a background isolate and streams
/// results in as they are found.
class DeepSearchPage extends StatefulWidget {
  const DeepSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<DeepSearchPage> createState() => _DeepSearchPageState();
}

class _DeepSearchPageState extends State<DeepSearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery ?? '',
  );

  StreamSubscription<DeepSearchEvent>? _subscription;
  final List<DeepHit> _hits = [];
  double _progress = 0;
  bool _running = false;
  String _query = '';

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final scope = Qamus.of(context);

    _subscription?.cancel();
    setState(() {
      _hits.clear();
      _progress = 0;
      _running = true;
      _query = stripMarks(text).trim();
    });

    _subscription = scope.dictionary
        .deepSearch(text, bookIds: scope.settings.selectedBooks)
        .listen(
          (event) {
            if (!mounted) return;
            setState(() {
              _hits.addAll(event.hits);
              _progress = event.fraction;
              if (event.done) _running = false;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() => _running = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('تعذّر البحث: $error')));
          },
          onDone: () {
            if (mounted) setState(() => _running = false);
          },
        );
  }

  void _stop() {
    _subscription?.cancel();
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = Qamus.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث في المعاني'),
        actions: [
          IconButton(
            tooltip: 'المعاجم',
            onPressed: () => showBooksSheet(context),
            icon: const Icon(Icons.library_books_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _running
              ? LinearProgressIndicator(value: _progress, minHeight: 2)
              : const SizedBox(height: 2),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _controller,
              autofocus: widget.initialQuery == null,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _start(),
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: 'كلمة أو عبارة داخل الشروح…',
                prefixIcon: const Icon(Icons.travel_explore_rounded),
                suffixIcon: IconButton(
                  tooltip: _running ? 'إيقاف' : 'ابحث',
                  onPressed: _running ? _stop : _start,
                  icon: Icon(
                    _running ? Icons.stop_rounded : Icons.arrow_back_rounded,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    countedResults(_hits.length),
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (_running)
                    Text(
                      '${arabicNumber((_progress * 100).round())}٪',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          Expanded(
            child: _hits.isEmpty
                ? EmptyNote(
                    icon: _running
                        ? Icons.hourglass_top_rounded
                        : Icons.manage_search_rounded,
                    title: _running
                        ? 'جارٍ التفتيش في الشروح…'
                        : 'ابحث داخل نصّ المعاجم',
                    detail: _running
                        ? 'يُفكّ ضغط الشروح ويُفتَّش فيها مقطعًا بعد مقطع'
                        : 'اعثر على الكلمة ولو لم تكن هي المدخل، بل ورَدت في شرحه',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: _hits.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final hit = _hits[index];
                      final book = scope.dictionary.book(hit.bookId);
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EntryPage(entryKey: hit.key),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hit.word,
                                      style: theme.textTheme.headlineSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (book != null)
                                    BookChip(book: book, dense: true),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _Excerpt(text: hit.excerpt, needle: _query),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Renders the excerpt with the matched phrase picked out in the accent colour.
class _Excerpt extends StatelessWidget {
  const _Excerpt({required this.text, required this.needle});

  final String text;
  final String needle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium!;
    if (needle.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final flat = stripMarks(text);
    // `flat` and `text` differ in length, so walk `text` and count only the
    // characters that survive mark-stripping.
    final marked = <bool>[];
    var flatIndex = 0;
    final matches = <int>{};
    for (
      var at = flat.indexOf(needle);
      at >= 0;
      at = flat.indexOf(needle, at + 1)
    ) {
      for (var i = at; i < at + needle.length; i++) {
        matches.add(i);
      }
    }
    for (final ch in text.split('')) {
      final survives = stripMarks(ch).isNotEmpty;
      marked.add(survives && matches.contains(flatIndex));
      if (survives) flatIndex++;
    }

    final buffer = StringBuffer();
    var inMatch = marked.isNotEmpty && marked.first;
    final chars = text.split('');
    for (var i = 0; i < chars.length; i++) {
      if (marked[i] != inMatch) {
        spans.add(
          TextSpan(
            text: buffer.toString(),
            style: inMatch
                ? TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.10,
                    ),
                  )
                : null,
          ),
        );
        buffer.clear();
        inMatch = marked[i];
      }
      buffer.write(chars[i]);
    }
    if (buffer.isNotEmpty) {
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: inMatch
              ? TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )
              : null,
        ),
      );
    }
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
