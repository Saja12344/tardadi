import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class _MapStop {
  const _MapStop({
    required this.label,
    required this.point,
    required this.trigger,
  });

  final String label;
  final Offset point;
  final double trigger;
}

class _MapGridLayout {
  _MapGridLayout(Size size)
      : pad = size.width * 0.06,
        streetWidth = size.width * 0.048,
        streetHeight = size.height * 0.052,
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

  List<Offset> routePoints() {
    final a = intersection(0, 0);
    final b = intersection(1, 1);
    final c = intersection(2, 2);
    return [a, Offset(a.dx, b.dy), b, Offset(b.dx, c.dy), c];
  }
}

class MapIllustration extends StatefulWidget {
  const MapIllustration({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

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
      duration: const Duration(milliseconds: 4200),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(MapIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_MapStop> _stopsFor(Size size) {
    final grid = _MapGridLayout(size);
    final points = grid.routePoints();
    return [
      _MapStop(label: 'A', point: points[0], trigger: 0.42),
      _MapStop(label: 'B', point: points[2], trigger: 0.58),
      _MapStop(label: 'C', point: points[4], trigger: 0.74),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const busSize = 26.0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value);
          final size = Size(widget.width, widget.height);
          final routePoints = _MapGridLayout(size).routePoints();
          final busProgress = ((progress - 0.28) / 0.58).clamp(0.0, 1.0);
          final busCenter = _pointOnPolyline(routePoints, busProgress);
          final busAngle = _segmentAngleAt(routePoints, busProgress);
          final busVisible = progress > 0.24;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CustomPaint(
                size: size,
                painter: _MapIllustrationPainter(
                  progress: progress,
                  stops: _stopsFor(size),
                  busProgress: busProgress,
                ),
              ),
              if (busVisible)
                Positioned(
                  left: busCenter.dx - busSize / 2,
                  top: busCenter.dy - busSize / 2,
                  child: Transform.rotate(
                    angle: busAngle + math.pi / 2,
                    child: _BusMarker(size: busSize),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BusMarker extends StatelessWidget {
  const _BusMarker({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OnboardingTheme.orange,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: OnboardingTheme.orange.withValues(alpha: 0.55),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.directions_bus_rounded,
        size: size * 0.62,
        color: Colors.white,
      ),
    );
  }
}

class _MapIllustrationPainter extends CustomPainter {
  _MapIllustrationPainter({
    required this.progress,
    required this.stops,
    required this.busProgress,
  });

  final double progress;
  final List<_MapStop> stops;
  final double busProgress;

  static const _blockColor = Color(0xFF1E2A5A);
  static const _streetColor = Color(0xFF263366);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = _MapGridLayout(size);
    final routePoints = grid.routePoints();

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = OnboardingTheme.card,
    );

    _drawAmbientGlow(canvas, size);
    _drawBlocks(canvas, grid);
    _drawStreets(canvas, grid);
    _drawRoute(canvas, routePoints, progress);
    _drawRouteGlow(canvas, routePoints, busProgress);

    for (final stop in stops) {
      final lit = busProgress >= stop.trigger;
      final pulse = lit
          ? 0.35 + math.sin((progress * math.pi * 4) + stop.trigger * 8) * 0.15
          : 0.0;
      _drawStopMarker(canvas, stop.point, stop.label, size, lit, pulse);
    }
  }

  void _drawAmbientGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          OnboardingTheme.orange.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawBlocks(Canvas canvas, _MapGridLayout grid) {
    final paint = Paint()..color = _blockColor;
    final radius = Radius.circular(grid.blockW.clamp(4.0, 7.0));

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

  void _drawRoute(Canvas canvas, List<Offset> points, double t) {
    final drawProgress = (t / 0.38).clamp(0.0, 1.0);
    if (drawProgress <= 0) return;

    final paint = Paint()
      ..color = OnboardingTheme.orange.withValues(alpha: 0.22)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_trimmedPolylinePath(points, drawProgress), paint);

    final activePaint = Paint()
      ..color = OnboardingTheme.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_trimmedPolylinePath(points, drawProgress), activePaint);
  }

  void _drawRouteGlow(Canvas canvas, List<Offset> points, double busT) {
    if (busT <= 0) return;

    final glowPaint = Paint()
      ..color = OnboardingTheme.orange.withValues(alpha: 0.35)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(_trimmedPolylinePath(points, busT), glowPaint);
  }

  void _drawStopMarker(
    Canvas canvas,
    Offset center,
    String label,
    Size size,
    bool lit,
    double pulse,
  ) {
    final ringRadius = size.width * 0.052;
    final glowRadius = ringRadius * (1.6 + pulse);

    if (lit) {
      canvas.drawCircle(
        center,
        glowRadius,
        Paint()
          ..color = OnboardingTheme.orange.withValues(alpha: 0.18 + pulse * 0.2)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = lit
            ? OnboardingTheme.orange
            : OnboardingTheme.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawCircle(
      center,
      ringRadius * 0.42,
      Paint()..color = lit ? Colors.white : OnboardingTheme.muted.withValues(alpha: 0.5),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: lit ? OnboardingTheme.orange : OnboardingTheme.muted,
          fontSize: size.width * 0.048,
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

  Path _trimmedPolylinePath(List<Offset> points, double t) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    final segments = <double>[];
    var total = 0.0;

    for (var i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      segments.add(len);
      total += len;
    }

    if (total == 0) return path;

    final target = total * t;
    var walked = 0.0;

    for (var i = 0; i < points.length - 1; i++) {
      final len = segments[i];
      if (walked + len >= target) {
        final local = ((target - walked) / len).clamp(0.0, 1.0);
        final end = Offset.lerp(points[i], points[i + 1], local)!;
        path.lineTo(end.dx, end.dy);
        break;
      }
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
      walked += len;
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _MapIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.busProgress != busProgress;
  }
}

Offset _pointOnPolyline(List<Offset> points, double t) {
  final segments = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    total += (points[i + 1] - points[i]).distance;
    segments.add(total);
  }
  if (total == 0) return points.first;

  final target = t * total;
  var walked = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    if (walked + len >= target) {
      final local = (target - walked) / len;
      return Offset.lerp(points[i], points[i + 1], local)!;
    }
    walked += len;
  }
  return points.last;
}

double _segmentAngleAt(List<Offset> points, double t) {
  final segments = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    total += (points[i + 1] - points[i]).distance;
    segments.add(total);
  }
  if (total == 0) return 0;

  final target = t * total;
  var walked = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    if (walked + len >= target) {
      final delta = points[i + 1] - points[i];
      return math.atan2(delta.dy, delta.dx);
    }
    walked += len;
  }
  return 0;
}
