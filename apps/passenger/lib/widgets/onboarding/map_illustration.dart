import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';
import 'tardadi_mark.dart';

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

/// Uniform city-block grid: 4×4 blocks with even streets and intersections.
class _MapGridLayout {
  _MapGridLayout(Size size)
      : pad = size.width * 0.04,
        streetWidth = size.width * 0.052,
        streetHeight = size.height * 0.058,
        cols = 4,
        rows = 4 {
    final contentW = size.width - pad * 2;
    final contentH = size.height - pad * 2;
    blockW = (contentW - streetWidth * (cols - 1)) / cols;
    blockH = (contentH - streetHeight * (rows - 1)) / rows;
  }

  final double pad;
  final double streetWidth;
  final double streetHeight;
  final int cols;
  final int rows;
  late final double blockW;
  late final double blockH;

  Rect blockRect(int col, int row) {
    return Rect.fromLTWH(
      pad + col * (blockW + streetWidth),
      pad + row * (blockH + streetHeight),
      blockW,
      blockH,
    );
  }

  /// Center of the crossing between blocks `(col, row)` and `(col + 1, row + 1)`.
  Offset intersection(int col, int row) {
    return Offset(
      pad + (col + 1) * blockW + (col + 0.5) * streetWidth,
      pad + (row + 1) * blockH + (row + 0.5) * streetHeight,
    );
  }

  List<Rect> allBlocks() {
    return [
      for (var row = 0; row < rows; row++)
        for (var col = 0; col < cols; col++) blockRect(col, row),
    ];
  }

  List<Rect> verticalStreets() {
    return [
      for (var i = 0; i < cols - 1; i++)
        Rect.fromLTWH(
          pad + (i + 1) * blockW + i * streetWidth,
          pad,
          streetWidth,
          rows * blockH + (rows - 1) * streetHeight,
        ),
    ];
  }

  List<Rect> horizontalStreets() {
    return [
      for (var i = 0; i < rows - 1; i++)
        Rect.fromLTWH(
          pad,
          pad + (i + 1) * blockH + i * streetHeight,
          cols * blockW + (cols - 1) * streetWidth,
          streetHeight,
        ),
    ];
  }

  /// Route A → B → C along street centers (L-shaped path).
  List<Offset> routePoints() {
    final a = intersection(0, 0);
    final b = intersection(1, 1);
    final c = intersection(2, 2);
    return [
      a,
      Offset(a.dx, b.dy),
      b,
      Offset(b.dx, c.dy),
      c,
    ];
  }

  List<Offset> routeFractions(Size size) {
    return [
      for (final point in routePoints())
        Offset(point.dx / size.width, point.dy / size.height),
    ];
  }
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

  List<_MapStop> _stopsFor(Size size) {
    final grid = _MapGridLayout(size);
    final fractions = grid.routeFractions(size);
    return [
      _MapStop(label: 'A', point: fractions[0], phase: 0.0),
      _MapStop(label: 'B', point: fractions[2], phase: 0.33),
      _MapStop(label: 'C', point: fractions[4], phase: 0.66),
    ];
  }

  List<Offset> _routePoints(Size size) {
    return _MapGridLayout(size).routePoints();
  }

  @override
  Widget build(BuildContext context) {
    const logoSize = 24.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final size = Size(widget.width, widget.height);
          final routePoints = _routePoints(size);
          final stops = _stopsFor(size);
          final logoCenter = _pointOnPolyline(routePoints, _controller.value);
          final logoAngle = _segmentAngleAt(routePoints, _controller.value);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CustomPaint(
                size: size,
                painter: _MapIllustrationPainter(
                  progress: _controller.value,
                  stops: stops,
                ),
              ),
                Positioned(
                  left: logoCenter.dx - logoSize / 2,
                  top: logoCenter.dy - logoSize / 2,
                  child: Transform.rotate(
                    angle: logoAngle,
                    child: const TardadiMark(size: logoSize),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapIllustrationPainter extends CustomPainter {
  _MapIllustrationPainter({
    required this.progress,
    required this.stops,
  });

  final double progress;
  final List<_MapStop> stops;

  static const _blockColor = OnboardingTheme.mapBlock;
  static const _streetColor = OnboardingTheme.mapStreet;
  static const _mapSurface = OnboardingTheme.mapSurface;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = _MapGridLayout(size);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _mapSurface,
    );

    // Soft cool bloom on the dark map.
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.48),
      size.width * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            OnboardingTheme.mapStreet.withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.48),
            radius: size.width * 0.42,
          ),
        ),
    );

    _drawBlocks(canvas, grid);
    _drawStreets(canvas, grid);

    final routePoints = grid.routePoints();
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

  void _drawBlocks(Canvas canvas, _MapGridLayout grid) {
    final paint = Paint()..color = _blockColor;
    final radius = Radius.circular(grid.blockW.clamp(4.0, 8.0));

    for (final block in grid.allBlocks()) {
      canvas.drawRRect(RRect.fromRectAndRadius(block, radius), paint);
    }
  }

  void _drawStreets(Canvas canvas, _MapGridLayout grid) {
    final paint = Paint()..color = _streetColor;
    const radius = Radius.circular(3);

    for (final street in [...grid.verticalStreets(), ...grid.horizontalStreets()]) {
      canvas.drawRRect(RRect.fromRectAndRadius(street, radius), paint);
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
      Paint()..color = OnboardingTheme.mapInk,
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
