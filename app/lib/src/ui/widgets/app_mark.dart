import 'package:flutter/material.dart';

import '../../theme.dart';

/// The app's mark: a violet gradient disc — the same wash the word-of-the-day
/// card wears — carrying the letter ق, optionally inside a turning ring.
///
/// This is the launcher icon rendered in Dart, so the first thing on screen is
/// the thing the reader just tapped rather than a different drawing of it.
class AppMark extends StatelessWidget {
  const AppMark({
    super.key,
    this.size = 120,
    this.progress = false,
    this.accent = QamusTheme.violet,
  });

  final double size;

  /// Wraps the disc in Material's indeterminate circular indicator — the arc
  /// that stretches and contracts as it turns, the one a phone shows while an
  /// app is being installed. Only the splash asks for it.
  final bool progress;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    // The ring needs room outside the disc, so the disc is inset when it is
    // there and fills the box when it is not.
    final ringRoom = progress ? size * 0.16 : 0.0;
    final disc = size - ringRoom * 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (progress)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                // A ring that never stops turning is a battery cost and
                // something no test can settle, so when the system asks for
                // reduced motion it freezes into the arc the launcher icon
                // wears — the same picture, holding still.
                value: MediaQuery.disableAnimationsOf(context) ? 0.72 : null,
                strokeWidth: size * 0.055,
                strokeCap: StrokeCap.round,
                // The track is the ring's own colour, faint, so the arc reads
                // as travelling around a circle rather than floating.
                backgroundColor: accent.withValues(alpha: 0.16),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          Container(
            width: disc,
            height: disc,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: QamusTheme.gradient(accent),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.36),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.07),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ق',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: QamusTheme.font,
                  fontSize: disc * 0.46,
                  height: 1.34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
