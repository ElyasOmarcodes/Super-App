import 'package:flutter/material.dart';

import '../app.dart';
import '../data/dictionary.dart';
import '../theme.dart';
import 'deep_search_page.dart';
import 'entry_page.dart';
import 'roots_page.dart';
import 'widgets/cards.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// What the reader lands on before typing anything: the word of the day, the
/// size of the corpus, the two other ways in, and the six lexicons.
class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.onOpen, required this.onSearch});

  final ValueChanged<String> onOpen;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final settings = scope.settings;
    final scheme = Theme.of(context).colorScheme;

    // One word per day, the same for everyone, chosen without a scan.
    final featured = scope.dictionary.wordOfDay(DateTime.now());

    final history = settings.history;
    final favourites = settings.favourites;

    var step = 0;
    Widget stagger(Widget child) => FadeSlideIn(
      delay: Duration(milliseconds: 55 * step++),
      child: child,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 150),
      children: [
        if (featured != null)
          stagger(
            _FeaturedCard(
              featured: featured,
              bookName: scope.dictionary.book(featured.bookId)?.name ?? '',
              onTap: () => onOpen(featured.key),
            ),
          ),
        const SizedBox(height: 14),
        stagger(
          _StatsRow(
            entries: scope.dictionary.entryCount,
            roots: scope.dictionary.rootCount,
            books: scope.dictionary.books.length,
          ),
        ),
        const SizedBox(height: 14),
        stagger(
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.account_tree_rounded,
                  accent: QamusTheme.blue,
                  title: strings.browseRoots,
                  detail: strings.browseRootsDetail,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const RootsPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.travel_explore_rounded,
                  accent: QamusTheme.emerald,
                  title: strings.deepSearch,
                  detail: strings.deepSearchDetail,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DeepSearchPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        stagger(
          SectionTitle(
            strings.sources,
            icon: Icons.auto_stories_rounded,
            tint: QamusTheme.violet,
          ),
        ),
        stagger(_LexiconStrip(total: scope.dictionary.entryCount)),
        if (favourites.isNotEmpty) ...[
          stagger(
            SectionTitle(
              strings.saved,
              icon: Icons.bookmark_rounded,
              tint: QamusTheme.rose,
            ),
          ),
          stagger(
            _Chips(
              records: favourites.take(14).toList(),
              tint: QamusTheme.rose,
              emphasised: true,
              onOpen: onOpen,
            ),
          ),
        ],
        if (history.isNotEmpty) ...[
          stagger(
            SectionTitle(
              strings.recentSearches,
              icon: Icons.history_rounded,
              tint: QamusTheme.cyan,
              trailing: TextButton(
                onPressed: settings.clearHistory,
                child: Text(strings.clear),
              ),
            ),
          ),
          stagger(
            _Chips(
              records: history.take(18).toList(),
              tint: QamusTheme.cyan,
              onOpen: onOpen,
            ),
          ),
        ],
        stagger(
          SectionTitle(
            strings.treasures,
            icon: Icons.auto_awesome_rounded,
            tint: QamusTheme.amber,
          ),
        ),
        stagger(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final word in kSampler)
                WordPill(word: word, onTap: () => onSearch(word)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        stagger(
          SurfaceCard(
            accent: QamusTheme.amber,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(
                  icon: Icons.tips_and_updates_rounded,
                  colour: QamusTheme.amber,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.suffixTip,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
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

const kSampler = [
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

/// The hero card: one word, its root, and the first line of its definition.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.featured,
    required this.bookName,
    required this.onTap,
  });

  final Featured featured;
  final String bookName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;

    return ColourCard(
      accent: QamusTheme.violet,
      onTap: onTap,
      watermark: Icons.auto_stories_rounded,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 7),
              Text(
                strings.treasures,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            featured.word,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          if (featured.preview.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              featured.preview,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.7,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (featured.root != null)
                _WhitePill(text: strings.rootOf(featured.root!)),
              if (featured.root != null) const SizedBox(width: 8),
              Flexible(child: _WhitePill(text: bookName, rtl: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({required this.text, this.rtl = false});

  final String text;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        textDirection: rtl ? TextDirection.rtl : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Three small colour cards: entries, roots, lexicons.
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.entries,
    required this.roots,
    required this.books,
  });

  final int entries;
  final int roots;
  final int books;

  @override
  Widget build(BuildContext context) {
    final strings = context.str;
    final theme = Theme.of(context);

    Widget cell(String value, String label, Color accent, IconData icon) =>
        Expanded(
          child: ColourCard(
            accent: accent,
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 19,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        cell(
          strings.n(entries),
          strings.entriesLabel,
          QamusTheme.cyan,
          Icons.article_rounded,
        ),
        const SizedBox(width: 10),
        cell(
          strings.n(roots),
          strings.rootsLabel,
          QamusTheme.amber,
          Icons.account_tree_rounded,
        ),
        const SizedBox(width: 10),
        cell(
          strings.n(books),
          strings.lexiconsLabel,
          QamusTheme.rose,
          Icons.menu_book_rounded,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, colour: accent, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: theme.textTheme.labelSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A horizontal strip of the six lexicons, each with its share of the corpus.
class _LexiconStrip extends StatelessWidget {
  const _LexiconStrip({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final books = scope.dictionary.books;

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final book = books[index];
          final colour = bookColor(book.id, scheme);
          final on = scope.settings.isBookSelected(book.id);
          return SizedBox(
            width: 172,
            child: SurfaceCard(
              accent: on ? colour : null,
              onTap: () => scope.settings.toggleBook(book.id),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(
                        icon: book.isThesaurus
                            ? Icons.swap_horiz_rounded
                            : Icons.menu_book_rounded,
                        colour: colour,
                        size: 30,
                      ),
                      const Spacer(),
                      AnimatedScale(
                        scale: on ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 17,
                          color: colour,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      book.name,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShareBar(
                    fraction: total == 0 ? 0 : book.count / total,
                    colour: colour,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.n(book.count),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.records,
    required this.tint,
    required this.onOpen,
    this.emphasised = false,
  });

  final List<String> records;
  final Color tint;
  final bool emphasised;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final record in records)
          Builder(
            builder: (context) {
              final item = decodeRecord(record);
              return WordPill(
                word: item.word,
                tint: tint,
                emphasised: emphasised,
                onTap: () => onOpen(item.key),
              );
            },
          ),
      ],
    );
  }
}

({String key, String word}) decodeRecord(String record) {
  final at = record.indexOf(' ');
  if (at < 0) return (key: record, word: record);
  return (key: record.substring(0, at), word: record.substring(at + 1));
}

/// Convenience for opening an entry from anywhere on the dashboard.
void openEntry(BuildContext context, String key) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => EntryPage(entryKey: key)));
}
