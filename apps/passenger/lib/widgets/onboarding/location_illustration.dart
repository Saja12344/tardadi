import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class _NearbyStop {
  const _NearbyStop({
    required this.label,
    required this.point,
    required this.phase,
  });

  final String label;
  final Offset point;
  final double phase;
}

class LocationIllustration extends StatefulWidget {
  const LocationIllustration({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<LocationIllustration> createState() => _LocationIllustrationState();
}

class _LocationIllustrationState extends State<LocationIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _stops = [
    _NearbyStop(label: '1', point: Offset(0.22, 0.30), phase: 0.0),
    _NearbyStop(label: '2', point: Offset(0.72, 0.24), phase: 0.25),
    _NearbyStop(label: '3', point: Offset(0.68, 0.72), phase: 0.5),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _LocationIllustrationPainter(
              progress: _controller.value,
              stops: _stops,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _LocationIllustrationPainter extends CustomPainter {
  const _LocationIllustrationPainter({
    required this.progress,
    required this.stops,
  });

  final double progress;
  final List<_NearbyStop> stops;

  static const _blockColor = OnboardingTheme.mapBlock;
  static const _streetColor = OnboardingTheme.mapStreet;
  static const _mapSurface = OnboardingTheme.mapSurface;
  static const _userCenter = Offset(0.46, 0.50);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _mapSurface,
    );

    canvas.drawCircle(
      Offset(size.width * 0.46, size.height * 0.50),
      size.width * 0.38,
      Paint()
        ..shader = RadialGradient(
          colors: [
            OnboardingTheme.mapStreet.withValues(alpha: 0.16),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.46, size.height * 0.50),
            radius: size.width * 0.38,
          ),
        ),
    );

    _drawBlocks(canvas, size);
    _drawStreets(canvas, size);

    final userCenter = Offset(
      _userCenter.dx * size.width,
      _userCenter.dy * size.height,
    );

    _drawNearbyRadius(canvas, userCenter, size, progress);

    for (final stop in stops) {
      final center = Offset(
        stop.point.dx * size.width,
        stop.point.dy * size.height,
      );
      final reveal = _stopReveal(progress, stop.phase);
      if (reveal <= 0) continue;

      _drawWalkLine(
        canvas,
        userCenter,
        center,
        reveal,
      );
      _drawStopMarker(canvas, center, stop.label, size, progress, stop.phase);
    }

    _drawUserLocation(canvas, userCenter, size, progress);
  }

  double _stopReveal(double t, double phase) {
    final start = phase * 0.55;
    final end = start + 0.35;
    if (t < start) return 0;
    if (t > end) return 1;
    return Curves.easeOut.transform((t - start) / (end - start));
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final paint = Paint()..color = _blockColor;
    final blocks = [
      Rect.fromLTWH(size.width * 0.04, size.height * 0.05, size.width * 0.20, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.34, size.height * 0.05, size.width * 0.22, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.66, size.height * 0.05, size.width * 0.28, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.30, size.width * 0.18, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.28, size.width * 0.16, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.30, size.width * 0.18, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.58, size.width * 0.18, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.56, size.width * 0.16, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.54, size.width * 0.18, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.82, size.width * 0.36, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.82, size.width * 0.36, size.height * 0.12),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(6)),
        paint,
      );
    }
  }

  void _drawStreets(Canvas canvas, Size size) {
    final paint = Paint()..color = _streetColor;

    final streets = [
      Rect.fromLTWH(size.width * 0.24, size.height * 0.05, size.width * 0.08, size.height * 0.90),
      Rect.fromLTWH(size.width * 0.50, size.height * 0.05, size.width * 0.06, size.height * 0.90),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.05, size.width * 0.04, size.height * 0.90),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.22, size.width * 0.92, size.height * 0.05),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.48, size.width * 0.92, size.height * 0.05),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.74, size.width * 0.92, size.height * 0.05),
    ];

    for (final street in streets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(street, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _drawNearbyRadius(
    Canvas canvas,
    Offset center,
    Size size,
    double t,
  ) {
    final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
    final radius = size.width * (0.24 + pulse * 0.04);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.08 + pulse * 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawWalkLine(
    Canvas canvas,
    Offset from,
    Offset to,
    double reveal,
  ) {
    final end = Offset.lerp(from, to, reveal)!;
    canvas.drawLine(
      from,
      end,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.35)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawStopMarker(
    Canvas canvas,
    Offset center,
    String label,
    Size size,
    double t,
    double phase,
  ) {
    final pulse = (t + phase) % 1.0;
    final ringRadius = size.width * 0.048;
    final pulseRadius = ringRadius * (1 + pulse * 0.7);
    final pulseOpacity = (1 - pulse) * 0.35;

    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = OnboardingTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawCircle(
      center,
      ringRadius * 0.38,
      Paint()..color = OnboardingTheme.mapInk,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: OnboardingTheme.orange,
          fontSize: size.width * 0.048,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center + Offset(ringRadius * 0.5, -textPainter.height * 0.85),
    );
  }

  void _drawUserLocation(
    Canvas canvas,
    Offset center,
    Size size,
    double t,
  ) {
    final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
    final outerRadius = size.width * 0.058 * (1 + pulse * 0.18);

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.18 + pulse * 0.12)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      size.width * 0.038,
      Paint()
        ..color = OnboardingTheme.mapInk
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      size.width * 0.038,
      Paint()
        ..color = OnboardingTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      center,
      size.width * 0.016,
      Paint()..color = OnboardingTheme.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _LocationIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
