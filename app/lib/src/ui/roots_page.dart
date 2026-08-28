import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/models.dart';
import 'entry_page.dart';
import 'widgets/common.dart';
import 'widgets/motion.dart';

/// Browsing by triliteral root — the way a printed Arabic lexicon is actually
/// organised. Pick a root, get every word derived from it.
class RootsPage extends StatefulWidget {
  const RootsPage({super.key, this.initialRoot});

  final String? initialRoot;

  @override
  State<RootsPage> createState() => _RootsPageState();
}

class _RootsPageState extends State<RootsPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialRoot ?? '',
  );
  Timer? _debounce;

  List<({int id, String root, int count})> _roots = const [];
  ({int id, String root})? _selected;
  List<Headword> _words = const [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _refresh(_controller.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _refresh(String query) {
    setState(() => _roots = context.qamus.dictionary.roots(query));
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 110), () => _refresh(value));
  }

  void _select(({int id, String root, int count}) root) {
    setState(() {
      _selected = (id: root.id, root: root.root);
      _words = context.qamus.dictionary.byRootId(root.id, limit: 300);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(title: Text(strings.rootsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                hintText: strings.rootHint,
                prefixIcon: const Icon(Icons.account_tree_rounded),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: _roots.isEmpty
                ? Center(
                    child: Text(
                      strings.noRoots,
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _roots.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final root = _roots[index];
                      return ChoiceChip(
                        label: Text(
                          root.root,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        selected: selected?.id == root.id,
                        onSelected: (_) => _select(root),
                      );
                    },
                  ),
          ),
          const Divider(height: 20),
          Expanded(
            child: selected == null
                ? EmptyNote(
                    icon: Icons.touch_app_rounded,
                    title: strings.chooseRoot,
                    detail: strings.chooseRootDetail,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      SectionTitle(
                        strings.derivativesOf(selected.root),
                        icon: Icons.account_tree_rounded,
                        trailing: Text(
                          strings.n(_words.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _words.length; i++)
                            FadeSlideIn(
                              delay: Duration(
                                milliseconds: 12 * i.clamp(0, 16),
                              ),
                              child: WordPill(
                                word: _words[i].word,
                                subtitle: strings.senses(_words[i].senseCount),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        EntryPage(entryKey: _words[i].key),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
