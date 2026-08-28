import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../theme.dart';
import 'books_sheet.dart';
import 'format.dart';

/// Reading preferences, the book filter, and the corpus credits.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = Qamus.of(context);
    final settings = scope.settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _Group(
            title: 'المظهر',
            children: [
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('فاتح'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('تلقائي'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('داكن'),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (value) =>
                    settings.setThemeMode(value.first),
                showSelectedIcon: false,
              ),
            ],
          ),
          _Group(
            title: 'القراءة',
            children: [
              Text('حجم نصّ الشروح', style: theme.textTheme.titleSmall),
              Row(
                children: [
                  const Icon(Icons.text_decrease_rounded, size: 18),
                  Expanded(
                    child: Slider(
                      value: settings.textScale,
                      min: 0.8,
                      max: 1.8,
                      divisions: 10,
                      label: '×${settings.textScale.toStringAsFixed(1)}',
                      onChanged: settings.setTextScale,
                    ),
                  ),
                  const Icon(Icons.text_increase_rounded, size: 22),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  settings.showVowels
                      ? 'الْعِلْمُ نُورٌ يَهْدِي صَاحِبَهُ'
                      : 'العلم نور يهدي صاحبه',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 20 * settings.textScale,
                  ),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: settings.showVowels,
                onChanged: settings.setShowVowels,
                title: Text(
                  'إظهار التشكيل',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'أخفِ الحركات إذا كنت تفضّل نصًّا مجرّدًا',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          _Group(
            title: 'المصادر',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.library_books_outlined),
                title: Text(
                  'المعاجم المفعّلة',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  settings.allBooksSelected
                      ? 'جميع المعاجم الستّة'
                      : '${countedBooks(settings.selectedBooks.length)} من '
                            '${arabicNumber(scope.dictionary.books.length)}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => showBooksSheet(context),
              ),
              const SizedBox(height: 6),
              for (final book in scope.dictionary.books)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: bookColor(book.id, theme.colorScheme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          book.name,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        arabicNumber(book.count),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _Group(
            title: 'عن التطبيق',
            children: [
              Text(
                'قاموس المعاني — معجم عربي عربي يعمل دون اتصال بالإنترنت، '
                'مبنيّ على ${arabicNumber(scope.dictionary.entryCount)} مدخلًا '
                'من ستّة معاجم، مضغوطة في ملف واحد داخل التطبيق.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('تراخيص الخطوط'),
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'قاموس المعاني',
                      applicationLegalese:
                          'خطّا Amiri و Tajawal مرخّصان بموجب SIL Open Font License 1.1',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('نسخ مسار قاعدة البيانات'),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: scope.dictionary.path),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('نُسخ المسار')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(color: theme.colorScheme.outlineVariant),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
