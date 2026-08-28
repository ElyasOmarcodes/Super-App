import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import 'widgets/motion.dart';

enum AboutSection { program, developer, how, licences }

/// One page for the four "about" topics, scrolled to the one that was tapped.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.section});

  final AboutSection section;

  @override
  Widget build(BuildContext context) {
    final scope = context.qamus;
    final strings = context.str;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final title = switch (section) {
      AboutSection.program => strings.aboutProgram,
      AboutSection.developer => strings.aboutDeveloper,
      AboutSection.how => strings.howItWorks,
      AboutSection.licences => strings.licenses,
    };

    final body = switch (section) {
      AboutSection.program => strings.aboutProgramBody(
        strings.n(scope.dictionary.entryCount),
        strings.n(scope.dictionary.books.length),
      ),
      AboutSection.developer => strings.aboutDeveloperBody,
      AboutSection.how => strings.howItWorksBody,
      AboutSection.licences => '',
    };

    final (icon, tint) = switch (section) {
      AboutSection.program => (Icons.info_rounded, QamusTheme.blue),
      AboutSection.developer => (Icons.person_rounded, QamusTheme.rose),
      AboutSection.how => (Icons.lightbulb_rounded, scheme.tertiary),
      AboutSection.licences => (
        Icons.workspace_premium_rounded,
        scheme.primary,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 48),
        children: [
          FadeSlideIn(
            child: Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 42, color: tint),
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (body.isNotEmpty)
            FadeSlideIn(
              delay: const Duration(milliseconds: 90),
              child: Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            ),
          if (section == AboutSection.program) ...[
            const SizedBox(height: 26),
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: _Facts(
                rows: [
                  (
                    strings.entriesLabel,
                    strings.n(scope.dictionary.entryCount),
                  ),
                  (strings.rootsLabel, strings.n(scope.dictionary.rootCount)),
                  (
                    strings.lexiconsLabel,
                    strings.n(scope.dictionary.books.length),
                  ),
                ],
              ),
            ),
          ],
          if (section == AboutSection.licences) ...[
            FadeSlideIn(
              delay: const Duration(milliseconds: 90),
              child: Text(_licenceNote, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: FilledButton.tonalIcon(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: strings.appName,
                  applicationLegalese: _licenceNote,
                ),
                icon: const Icon(Icons.description_rounded),
                label: Text(strings.fontLicenses),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _licenceNote =
    'Vazirmatn is used under the SIL Open Font License 1.1. '
    'The dictionary content belongs to its respective publishers.';

class _Facts extends StatelessWidget {
  const _Facts({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(QamusTheme.radius),
        border: Border.all(color: scheme.outlineVariant),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: 0.07),
            QamusTheme.amber.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          for (final (label, value) in rows)
            Expanded(
              child: Column(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                  Text(label, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
