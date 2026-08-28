import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/arabic.dart';
import '../data/models.dart';
import '../theme.dart';
import 'books_sheet.dart';
import 'widgets/cards.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// One headword in full: every sense from every selected book, its root, its
/// derivations, and the words that sit closest to it in the lexicon.
class EntryPage extends StatefulWidget {
  const EntryPage({super.key, required this.entryKey});

  final String entryKey;

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  EntryDetail? _detail;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final scope = context.qamus;
    // Look the entry up across every book: hiding senses that the reader
    // filtered out of *search* would make the page look broken.
    final detail = scope.dictionary.entry(widget.entryKey);
    if (detail != null) {
      scope.settings.remember(detail.key, detail.word);
    }
    setState(() => _detail = detail);
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final strings = context.str;
    final theme = Theme.of(context);

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyNote(
          icon: Icons.search_off_rounded,
          title: strings.notFound,
        ),
      );
    }

    final scope = context.qamus;
    final settings = scope.settings;
    final isFavourite = settings.isFavourite(detail.key);
    final selected = settings.selectedBooks;
    final visible = detail.senses
        .where((s) => selected.contains(s.bookId))
        .toList();
    final hidden = detail.senses.length - visible.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 172,
            actions: [
              IconButton(
                tooltip: isFavourite ? strings.unsaveWord : strings.saveWord,
                onPressed: () =>
                    settings.toggleFavourite(detail.key, detail.word),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: child,
                  ),
                  child: Icon(
                    isFavourite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    key: ValueKey(isFavourite),
                    color: isFavourite ? QamusTheme.rose : null,
                  ),
                ),
              ),
              IconButton(
                tooltip: strings.copyEntry,
                onPressed: () => _copy(context, detail, scope),
                icon: const Icon(Icons.copy_all_rounded),
              ),
              IconButton(
                tooltip: strings.lexicons,
                onPressed: () => showBooksSheet(context),
                icon: const Icon(Icons.library_books_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                bottom: 14,
                end: 130,
              ),
              title: Text(
                detail.word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: _Banner(detail: detail),
            ),
          ),
          if (hidden > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _Notice(
                  text: strings.hiddenSenses(hidden),
                  action: strings.showAll,
                  onAction: settings.selectAllBooks,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            sliver: SliverList.builder(
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final sense = visible[index];
                final book = scope.dictionary.book(sense.bookId);
                final isFirstOfBook =
                    index == 0 || visible[index - 1].bookId != sense.bookId;
                return FadeSlideIn(
                  delay: Duration(milliseconds: 45 * index.clamp(0, 8)),
                  child: _SenseCard(
                    sense: sense,
                    book: book,
                    showBookHeader: isFirstOfBook,
                  ),
                );
              },
            ),
          ),
          if (detail.sameRoot.isNotEmpty)
            SliverToBoxAdapter(
              child: _WordSection(
                title: detail.root == null
                    ? strings.fromRoot
                    : strings.derivativesOf(detail.root!),
                icon: Icons.account_tree_rounded,
                tint: theme.colorScheme.primary,
                words: detail.sameRoot,
              ),
            ),
          if (detail.similar.isNotEmpty)
            SliverToBoxAdapter(
              child: _WordSection(
                title: strings.similarWords,
                icon: Icons.hub_rounded,
                tint: QamusTheme.amber,
                words: detail.similar,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  void _copy(BuildContext context, EntryDetail detail, Qamus scope) {
    final buffer = StringBuffer('${detail.word}\n');
    if (detail.root != null) buffer.writeln('${detail.root}');
    for (final sense in detail.senses) {
      buffer.writeln('\n[${scope.dictionary.book(sense.bookId)?.name ?? ''}]');
      for (final line in sense.lines) {
        buffer.writeln('• $line');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.str.copied)));
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.detail});

  final EntryDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            QamusTheme.violet.withValues(alpha: 0.22),
            QamusTheme.blue.withValues(alpha: 0.10),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          // The headword itself is drawn by the FlexibleSpaceBar title, which
          // scales it down as the bar collapses; the banner only adds the
          // metadata line that sits above it.
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (detail.root != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: QamusTheme.violet.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        strings.rootOf(detail.root!),
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: QamusTheme.violet,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      '${strings.senses(detail.senses.length)} · '
                      '${strings.books(detail.senses.map((s) => s.bookId).toSet().length)}',
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenseCard extends StatelessWidget {
  const _SenseCard({
    required this.sense,
    required this.book,
    required this.showBookHeader,
  });

  final Sense sense;
  final Book? book;
  final bool showBookHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;
    final settings = context.qamus.settings;
    final color = bookColor(sense.bookId, theme.colorScheme);
    final bodyStyle = theme.textTheme.bodyLarge!.copyWith(
      fontSize: 18 * settings.textScale,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBookHeader && book != null)
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 10),
            child: Row(
              children: [
                BookChip(book: book!),
                const SizedBox(width: 10),
                Expanded(child: Divider(color: color.withValues(alpha: 0.28))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.showVowels ? sense.word : stripMarks(sense.word),
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontSize: 20 * settings.textScale,
                  ),
                ),
                const SizedBox(height: 8),
                if (sense.lines.isEmpty)
                  Text(strings.noDefinition, style: theme.textTheme.bodySmall)
                else
                  for (var i = 0; i < sense.lines.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsetsDirectional.only(
                              top: 12,
                              end: 10,
                            ),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: SelectableText(
                              settings.showVowels
                                  ? sense.lines[i]
                                  : stripMarks(sense.lines[i]),
                              textDirection: TextDirection.rtl,
                              style: bodyStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WordSection extends StatelessWidget {
  const _WordSection({
    required this.title,
    required this.icon,
    required this.tint,
    required this.words,
  });

  final String title;
  final IconData icon;
  final Color tint;
  final List<Headword> words;

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title, icon: icon, tint: tint),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final word in words)
                WordPill(
                  word: word.word,
                  subtitle: strings.senses(word.senseCount),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => EntryPage(entryKey: word.key),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.text,
    required this.action,
    required this.onAction,
  });

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 6, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}
