import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class _MapStop {
  const _MapStop({
    required this.label,
    required this.point,
    required this.phase,
  });

  final String label;
  final Offset point;
  final double phase;
}

class MapIllustration extends StatefulWidget {
  const MapIllustration({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<MapIllustration> createState() => _MapIllustrationState();
}

class _MapIllustrationState extends State<MapIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _routeFractions = [
    Offset(0.30, 0.24),
    Offset(0.30, 0.50),
    Offset(0.50, 0.50),
    Offset(0.50, 0.78),
    Offset(0.78, 0.78),
  ];

  static final _stops = [
    _MapStop(label: 'A', point: _routeFractions[0], phase: 0.0),
    _MapStop(label: 'B', point: _routeFractions[2], phase: 0.33),
    _MapStop(label: 'C', point: _routeFractions[4], phase: 0.66),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Offset> _routePoints(Size size) {
    return [
      for (final fraction in _routeFractions)
        Offset(fraction.dx * size.width, fraction.dy * size.height),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const logoSize = 24.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final size = Size(widget.width, widget.height);
            final routePoints = _routePoints(size);
            final logoCenter = _pointOnPolyline(routePoints, _controller.value);
            final logoAngle = _segmentAngleAt(routePoints, _controller.value);

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                CustomPaint(
                  size: size,
                  painter: _MapIllustrationPainter(
                    progress: _controller.value,
                    routeFractions: _routeFractions,
                    stops: _stops,
                  ),
                ),
                Positioned(
                  left: logoCenter.dx - logoSize / 2,
                  top: logoCenter.dy - logoSize / 2,
                  child: Transform.rotate(
                    angle: logoAngle,
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: logoSize,
                      height: logoSize,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapIllustrationPainter extends CustomPainter {
  _MapIllustrationPainter({
    required this.progress,
    required this.routeFractions,
    required this.stops,
  });

  final double progress;
  final List<Offset> routeFractions;
  final List<_MapStop> stops;

  static const _blockColor = Color(0xFFC8CDD8);
  static const _streetColor = Color(0xFFF2F4F8);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = OnboardingTheme.background,
    );

    _drawBlocks(canvas, size);
    _drawStreets(canvas, size);

    final routePoints = [
      for (final fraction in routeFractions)
        Offset(fraction.dx * size.width, fraction.dy * size.height),
    ];

    _drawAnimatedRoute(canvas, routePoints, progress);

    for (final stop in stops) {
      final center = Offset(
        stop.point.dx * size.width,
        stop.point.dy * size.height,
      );
      _drawAnimatedMarker(
        canvas,
        center,
        stop.label,
        size,
        (progress + stop.phase) % 1.0,
      );
    }
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final paint = Paint()..color = _blockColor;
    final blocks = [
      Rect.fromLTWH(size.width * 0.04, size.height * 0.04, size.width * 0.22, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.36, size.height * 0.04, size.width * 0.24, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.68, size.height * 0.04, size.width * 0.26, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.28, size.width * 0.20, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.24, size.width * 0.18, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.28, size.width * 0.18, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.56, size.width * 0.20, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.56, size.height * 0.56, size.width * 0.18, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.52, size.width * 0.18, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.82, size.width * 0.38, size.height * 0.12),
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
    final paint = Paint()
      ..color = _streetColor
      ..style = PaintingStyle.fill;

    final streets = [
      Rect.fromLTWH(size.width * 0.26, size.height * 0.04, size.width * 0.08, size.height * 0.92),
      Rect.fromLTWH(size.width * 0.48, size.height * 0.04, size.width * 0.06, size.height * 0.92),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.04, size.width * 0.04, size.height * 0.92),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.20, size.width * 0.92, size.height * 0.06),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.44, size.width * 0.92, size.height * 0.06),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.70, size.width * 0.92, size.height * 0.06),
    ];

    for (final street in streets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(street, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _drawAnimatedRoute(Canvas canvas, List<Offset> points, double t) {
    final paint = Paint()
      ..color = OnboardingTheme.orange
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 7.0;
    const gapLength = 6.0;
    final dashOffset = t * (dashLength + gapLength);

    for (var i = 0; i < points.length - 1; i++) {
      _drawDashedSegment(
        canvas,
        points[i],
        points[i + 1],
        paint,
        dashLength,
        gapLength,
        dashOffset,
      );
    }
  }

  void _drawDashedSegment(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLength,
    double gapLength,
    double dashOffset,
  ) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;

    final direction = delta / distance;
    var drawn = -dashOffset % (dashLength + gapLength);
    if (drawn < 0) drawn += dashLength + gapLength;
    var drawDash = drawn < dashLength;

    while (drawn < distance) {
      final segment = drawDash ? dashLength : gapLength;
      final next = math.min(drawn + segment, distance);
      if (drawDash && next > 0) {
        canvas.drawLine(
          start + direction * math.max(0, drawn),
          start + direction * next,
          paint,
        );
      }
      drawn = next;
      drawDash = !drawDash;
    }
  }

  void _drawAnimatedMarker(
    Canvas canvas,
    Offset center,
    String label,
    Size size,
    double pulse,
  ) {
    final ringRadius = size.width * 0.055;
    final pulseRadius = ringRadius * (1 + pulse * 0.85);
    final pulseOpacity = (1 - pulse) * 0.45;

    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = OnboardingTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      center,
      ringRadius * 0.42,
      Paint()..color = Colors.white,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: OnboardingTheme.orange,
          fontSize: size.width * 0.055,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center + Offset(ringRadius * 0.55, -textPainter.height * 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _MapIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

Offset _pointOnPolyline(List<Offset> points, double t) {
  final segments = <Offset>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    segments.add(Offset(total, len));
    total += len;
  }
  if (total == 0) return points.first;

  final target = (t * total) % total;
  var walked = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = segments[i].dy;
    if (walked + len >= target) {
      final local = (target - walked) / len;
      return Offset.lerp(points[i], points[i + 1], local)!;
    }
    walked += len;
  }
  return points.last;
}

double _segmentAngleAt(List<Offset> points, double t) {
  final segments = <Offset>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    segments.add(Offset(total, len));
    total += len;
  }
  if (total == 0) return 0;

  final target = (t * total) % total;
  var walked = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = segments[i].dy;
    if (walked + len >= target) {
      final delta = points[i + 1] - points[i];
      return math.atan2(delta.dy, delta.dx);
    }
    walked += len;
  }
  return 0;
}
