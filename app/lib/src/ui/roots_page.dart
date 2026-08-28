import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/models.dart';
import 'format.dart';
import 'entry_page.dart';
import 'widgets/common.dart';

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
    final dictionary = Qamus.of(context).dictionary;
    setState(() => _roots = dictionary.roots(query));
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 110), () => _refresh(value));
  }

  void _select(({int id, String root, int count}) root) {
    final dictionary = Qamus.of(context).dictionary;
    setState(() {
      _selected = (id: root.id, root: root.root);
      _words = dictionary.byRootId(root.id, limit: 300);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(title: const Text('الجذور')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: theme.textTheme.headlineSmall,
              decoration: const InputDecoration(
                hintText: 'اكتب أوّل حروف الجذر…',
                prefixIcon: Icon(Icons.account_tree_outlined),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: _roots.isEmpty
                ? Center(
                    child: Text(
                      'لا جذور مطابقة',
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
                      final on = selected?.id == root.id;
                      return ChoiceChip(
                        label: Text(
                          root.root,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        selected: on,
                        onSelected: (_) => _select(root),
                      );
                    },
                  ),
          ),
          const Divider(height: 20),
          Expanded(
            child: selected == null
                ? const EmptyNote(
                    icon: Icons.touch_app_outlined,
                    title: 'اختر جذرًا',
                    detail: 'ستظهر هنا كل الكلمات المشتقّة منه',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      SectionTitle(
                        'مشتقّات «${selected.root}»',
                        trailing: Text(
                          arabicNumber(_words.length),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final word in _words)
                            WordPill(
                              word: word.word,
                              subtitle: countedSenses(word.senseCount),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => EntryPage(entryKey: word.key),
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
