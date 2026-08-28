import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fades and lifts its child into place once, after [delay].
///
/// Staggering a list by index — `delay: Duration(milliseconds: 40 * i)` — is
/// what makes a screen feel like it assembles itself rather than snapping in.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 0.10),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Readers who ask the system to reduce motion get the end state at once.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Shrinks slightly while held, which gives every tap a physical answer.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (widget.onTap == null || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The eight-point star of Islamic book illumination, turning slowly.
///
/// It is the app's one piece of ornament: the setup screen, the language
/// picker and the drawer header all wear it.
class Rosette extends StatefulWidget {
  const Rosette({
    super.key,
    this.size = 128,
    this.child,
    this.primary,
    this.accent,
    this.spin = true,
  });

  final double size;
  final Widget? child;
  final Color? primary;
  final Color? accent;
  final bool spin;

  @override
  State<Rosette> createState() => _RosetteState();
}

class _RosetteState extends State<Rosette> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant Rosette oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// A never-ending animation is both a battery cost and something no test
  /// can ever settle, so it stops whenever motion is reduced.
  void _sync() {
    final animate = widget.spin && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _RosettePainter(
            turn: _controller.value,
            primary: widget.primary ?? scheme.primary,
            accent: widget.accent ?? scheme.tertiary,
          ),
          child: child,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class _RosettePainter extends CustomPainter {
  _RosettePainter({
    required this.turn,
    required this.primary,
    required this.accent,
  });

  final double turn;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    void star(double rotation, double scale, Color color, double stroke) {
      final path = Path();
      const points = 8;
      for (var i = 0; i <= points * 2; i++) {
        final angle = rotation + i * math.pi / points;
        final r = radius * scale * (i.isEven ? 1 : 0.62);
        final point = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
        i == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    star(
      turn * 2 * math.pi,
      1,
      primary.withValues(alpha: 0.30),
      size.width * 0.011,
    );
    star(
      -turn * 2 * math.pi + math.pi / 8,
      0.80,
      accent.withValues(alpha: 0.55),
      size.width * 0.009,
    );
    canvas.drawCircle(
      centre,
      radius * 0.54,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008
        ..color = primary.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _RosettePainter old) =>
      old.turn != turn || old.primary != primary || old.accent != accent;
}

/// A slow, drifting wash of colour behind hero areas.
///
/// Two blurred blobs orbiting on a long cycle — enough motion to feel alive,
/// slow enough never to pull the eye off the text.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child, this.colors});

  final Widget child;
  final List<Color>? colors;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = widget.colors ?? [scheme.primary, scheme.tertiary];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(math.cos(t) * 0.55, -0.75 + math.sin(t) * 0.18),
              radius: 1.15,
              colors: [
                colors.first.withValues(alpha: 0.16),
                colors.last.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
