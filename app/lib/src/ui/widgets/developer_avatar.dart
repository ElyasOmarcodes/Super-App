import 'package:flutter/material.dart';

import '../../theme.dart';

/// The author's portrait: square, circular, and ringed by a sweep of all six
/// of the app's accents — the same six that colour the lexicons.
///
/// One widget rather than two copies, so the profile page and the intro card
/// wear exactly the same ring, the same hairline and the same shadow.
class DeveloperAvatar extends StatelessWidget {
  const DeveloperAvatar({super.key, this.size = 148});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            QamusTheme.violet,
            QamusTheme.blue,
            QamusTheme.cyan,
            QamusTheme.emerald,
            QamusTheme.amber,
            QamusTheme.rose,
            QamusTheme.violet,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: QamusTheme.violet.withValues(alpha: 0.35),
            blurRadius: size * 0.19,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      // A hairline of the page's own colour between ring and photograph,
      // which is what makes the ring read as a stroke rather than as a
      // coloured edge of the picture.
      padding: EdgeInsets.all(size * 0.027),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surface,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.020),
          child: ClipOval(
            child: Image.asset(
              'assets/img/developer.jpg',
              fit: BoxFit.cover,
              // A missing asset must never take the page down with it.
              errorBuilder: (context, _, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: QamusTheme.gradient(QamusTheme.violet),
                ),
                child: Center(
                  child: Text(
                    'EO',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontFamily: QamusTheme.font,
                      fontSize: size * 0.2,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
