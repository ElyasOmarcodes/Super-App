import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../theme.dart';
import '../widgets/motion.dart';

/// Three cards introducing what the app is for, each with its own painted
/// emblem and its own accent colour.
class IntroPages extends StatefulWidget {
  const IntroPages({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<IntroPages> createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  final _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.str;
    final scheme = theme.colorScheme;

    final pages = [
      (
        title: strings.introTitle1,
        body: strings.introBody1,
        icon: Icons.auto_stories_rounded,
        colour: scheme.primary,
        emblem: _Emblem.shelf,
      ),
      (
        title: strings.introTitle2,
        body: strings.introBody2,
        icon: Icons.manage_search_rounded,
        colour: QamusTheme.amber,
        emblem: _Emblem.lens,
      ),
      (
        title: strings.introTitle3,
        body: strings.introBody3,
        icon: Icons.hub_rounded,
        colour: QamusTheme.rose,
        emblem: _Emblem.branches,
      ),
    ];

    final last = _page >= pages.length - 1 - 0.02;

    return Scaffold(
      body: AuroraBackground(
        colors: [
          pages[_page.round().clamp(0, pages.length - 1)].colour,
          scheme.tertiary,
        ],
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    child: TextButton(
                      onPressed: last ? null : widget.onDone,
                      child: Text(strings.skip),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    // How far this page is from the viewport centre, used to
                    // slide the emblem at a different rate from the text.
                    final delta = index - _page;
                    final page = pages[index];
                    return _IntroCard(
                      title: page.title,
                      body: page.body,
                      icon: page.icon,
                      colour: page.colour,
                      emblem: page.emblem,
                      parallax: delta,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 26),
                child: Column(
                  children: [
                    _Dots(count: pages.length, page: _page),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (last) {
                            widget.onDone();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        icon: Icon(
                          last
                              ? Icons.auto_awesome_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          last ? strings.start : strings.next,
                          style: theme.textTheme.labelLarge,
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.colour,
    required this.emblem,
    required this.parallax,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color colour;
  final _Emblem emblem;
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = (1 - parallax.abs()).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(parallax * -70, 0),
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: 210,
                height: 210,
                child: CustomPaint(
                  painter: _EmblemPainter(emblem: emblem, colour: colour),
                  child: Center(child: Icon(icon, size: 56, color: colour)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Transform.translate(
            offset: Offset(parallax * -26, 0),
            child: Opacity(
              opacity: opacity,
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.95,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Emblem { shelf, lens, branches }

/// A geometric backdrop per intro page, drawn rather than shipped as an image.
class _EmblemPainter extends CustomPainter {
  _EmblemPainter({required this.emblem, required this.colour});

  final _Emblem emblem;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(
      centre,
      r * 0.82,
      Paint()..color = colour.withValues(alpha: 0.08),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = colour.withValues(alpha: 0.42);

    switch (emblem) {
      case _Emblem.shelf:
        // Six concentric arcs — one per lexicon.
        for (var i = 0; i < 6; i++) {
          final radius = r * (0.32 + i * 0.11);
          canvas.drawArc(
            Rect.fromCircle(center: centre, radius: radius),
            -math.pi * 0.9 + i * 0.12,
            math.pi * 1.2,
            false,
            stroke,
          );
        }
      case _Emblem.lens:
        // A ring with tick marks, opening left and right: prefix and suffix.
        canvas.drawCircle(centre, r * 0.64, stroke);
        for (var i = 0; i < 24; i++) {
          final angle = i * math.pi / 12;
          final inner = r * (i.isEven ? 0.72 : 0.76);
          final outer = r * 0.86;
          canvas.drawLine(
            centre + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
            centre + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
            stroke,
          );
        }
      case _Emblem.branches:
        // A root with derivations radiating from it.
        for (var i = 0; i < 9; i++) {
          final angle = -math.pi / 2 + (i - 4) * 0.34;
          final end =
              centre +
              Offset(math.cos(angle) * r * 0.86, math.sin(angle) * r * 0.86);
          canvas.drawLine(centre + Offset(0, r * 0.1), end, stroke);
          canvas.drawCircle(
            end,
            3.5,
            Paint()..color = colour.withValues(alpha: 0.55),
          );
        }
        canvas.drawCircle(
          centre + Offset(0, r * 0.1),
          6,
          Paint()..color = colour.withValues(alpha: 0.7),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter old) =>
      old.emblem != emblem || old.colour != colour;
}

/// Page indicator whose active dot stretches into a capsule.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.page});

  final int count;
  final double page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8 + 20 * t,
                height: 8,
                decoration: BoxDecoration(
                  color: Color.lerp(scheme.outlineVariant, scheme.primary, t),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
      ],
    );
  }
}
