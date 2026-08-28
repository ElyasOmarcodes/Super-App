import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/bootstrap.dart';
import '../theme.dart';

/// Shown once, on the very first launch, while the shipped archive is unpacked
/// and the search indexes are built on the device.
class SetupPage extends StatelessWidget {
  const SetupPage({
    super.key,
    required this.progress,
    required this.onRetry,
    this.error,
  });

  final Stream<BootstrapProgress> progress;
  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: error != null
                ? _Failure(error: error!, onRetry: onRetry)
                : StreamBuilder<BootstrapProgress>(
                    stream: progress,
                    builder: (context, snapshot) {
                      final value =
                          snapshot.data ??
                          const BootstrapProgress(BootstrapStage.idle, -1);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _Seal(),
                          const SizedBox(height: 36),
                          Text(
                            'قاموس المعاني',
                            style: theme.textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'معجم عربي — عربي بين يديك، دون اتصال',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 44),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: value.fraction < 0 ? null : value.fraction,
                              minHeight: 6,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHigh,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(value.title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'يحدث هذا مرّة واحدة فقط',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 20),
        Text('تعذّر تجهيز المعجم', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          '$error',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}

/// A slowly rotating geometric rosette — an eight-point star, the motif that
/// runs through Islamic book illumination.
class _Seal extends StatefulWidget {
  const _Seal();

  @override
  State<_Seal> createState() => _SealState();
}

class _SealState extends State<_Seal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 128,
      height: 128,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _RosettePainter(
            turn: _controller.value,
            primary: scheme.primary,
            accent: QamusTheme.gold,
          ),
          child: child,
        ),
        child: Center(
          child: Text(
            'ق',
            style: TextStyle(
              fontFamily: QamusTheme.display,
              fontSize: 46,
              height: 1.35,
              color: scheme.primary,
            ),
          ),
        ),
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

    star(turn * 2 * math.pi, 1, primary.withValues(alpha: 0.30), 1.4);
    star(
      -turn * 2 * math.pi + math.pi / 8,
      0.80,
      accent.withValues(alpha: 0.55),
      1.2,
    );
    canvas.drawCircle(
      centre,
      radius * 0.54,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = primary.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _RosettePainter old) =>
      old.turn != turn || old.primary != primary || old.accent != accent;
}
