import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// The app's mark: a scalloped disc — the wavy circle of Material's newer
/// loading indicator — carrying the letter ق, inside a soft halo.
///
/// This is the launcher icon rendered in Dart, so the first thing on screen is
/// the thing the reader just tapped rather than a different drawing of it. On
/// the splash the scalloped ring turns and breathes; everywhere else it holds
/// the pose the icon is frozen in.
class AppMark extends StatefulWidget {
  const AppMark({
    super.key,
    this.size = 120,
    this.progress = false,
    this.accent = QamusTheme.violet,
  });

  final double size;

  /// Turns the scalloped ring, the way a phone turns its indicator while an
  /// app is being installed. Only the splash asks for it.
  final bool progress;

  final Color accent;

  @override
  State<AppMark> createState() => _AppMarkState();
}

class _AppMarkState extends State<AppMark> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AppMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// A ring that never stops turning is a battery cost and something no test
  /// can ever settle, so it stops whenever motion is reduced — and freezes at
  /// the angle the launcher icon is drawn at.
  void _sync() {
    final animate = widget.progress && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_turn.isAnimating) {
      _turn.repeat();
    } else if (!animate && _turn.isAnimating) {
      _turn.stop();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _turn,
        builder: (context, child) => CustomPaint(
          painter: _MarkPainter(
            turn: _turn.value,
            accent: widget.accent,
            // The gradient is anchored to the start corner, which a painter
            // cannot resolve on its own.
            textDirection: Directionality.of(context),
          ),
          child: child,
        ),
        child: Center(
          child: Text(
            'ق',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: QamusTheme.font,
              fontSize: widget.size * 0.30,
              height: 1.34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({
    required this.turn,
    required this.accent,
    required this.textDirection,
  });

  /// 0…1 around one full revolution.
  final double turn;
  final Color accent;
  final TextDirection textDirection;

  /// How many lobes the scalloped edge has, and how far they swell. Enough to
  /// read as a flower at a glance, gentle enough to stay a circle.
  static const _lobes = 10;
  static const _swell = 0.075;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // The halo: a soft disc the scalloped shape floats inside.
    canvas.drawCircle(
      centre,
      radius,
      Paint()..color = accent.withValues(alpha: 0.16),
    );

    final angle = turn * 2 * math.pi;
    // The lobes breathe as they turn, which is what keeps the shape alive
    // rather than merely spinning.
    final swell = _swell * (0.82 + 0.18 * math.sin(angle * 3));
    final path = scallopedPath(
      centre: centre,
      radius: radius * 0.66,
      rotation: angle,
      lobes: _lobes,
      swell: swell,
    );

    canvas.drawShadow(path, accent.withValues(alpha: 0.7), radius * 0.09, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = QamusTheme.gradient(accent).createShader(
          Rect.fromCircle(center: centre, radius: radius * 0.72),
          textDirection: textDirection,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) =>
      old.turn != turn ||
      old.accent != accent ||
      old.textDirection != textDirection;
}

/// The wavy circle both the launcher icon and the splash are built from.
///
/// A radius that swells and shrinks [lobes] times around the circle, joined
/// with cubic segments so the edge stays smooth rather than faceted.
Path scallopedPath({
  required Offset centre,
  required double radius,
  required double rotation,
  int lobes = 10,
  double swell = 0.075,
}) {
  const steps = 240;
  final path = Path();
  for (var i = 0; i <= steps; i++) {
    final t = i / steps * 2 * math.pi;
    final r = radius * (1 + swell * math.cos(lobes * (t - rotation)));
    final point = centre + Offset(math.cos(t) * r, math.sin(t) * r);
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}
