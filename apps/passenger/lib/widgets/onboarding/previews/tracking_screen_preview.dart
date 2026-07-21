import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../onboarding_stagger_reveal.dart';
import '../onboarding_theme.dart';
import '../onboarding_typography.dart';

class TrackingScreenPreview extends StatefulWidget {
  const TrackingScreenPreview({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

  @override
  State<TrackingScreenPreview> createState() => _TrackingScreenPreviewState();
}

class _TrackingScreenPreviewState extends State<TrackingScreenPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _route = [
    Offset(0.12, 0.78),
    Offset(0.28, 0.62),
    Offset(0.48, 0.52),
    Offset(0.68, 0.38),
    Offset(0.86, 0.28),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: OnboardingPreviewMotion.entrance,
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(TrackingScreenPreview oldWidget) {
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

  double get _s =>
      math.min(widget.width / 320, widget.height / 252);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final routeDraw = OnboardingPreviewMotion.step(1)
            .transform(t)
            .clamp(0.0, 1.0);
        final busT = OnboardingPreviewMotion.step(2)
            .transform(t)
            .clamp(0.0, 1.0);
        final etaT = OnboardingPreviewMotion.step(3).transform(t);
        final cardT = OnboardingPreviewMotion.step(4).transform(t);

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _LightMapPainter(
                  routeDraw: routeDraw,
                  busT: busT,
                  route: _route,
                ),
              ),
              Positioned(
                right: 12 * _s,
                top: 12 * _s,
                child: Opacity(
                  opacity: etaT,
                  child: Transform.translate(
                    offset: Offset(0, (1 - etaT) * 8),
                    child: _EtaChip(
                      scale: _s,
                      minutes: (5 - busT * 3).round().clamp(2, 5),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12 * _s,
                right: 12 * _s,
                bottom: 12 * _s,
                child: Opacity(
                  opacity: cardT,
                  child: Transform.translate(
                    offset: Offset(0, (1 - cardT) * 12),
                    child: _FloatingInfoCard(scale: _s, minutes: 3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EtaChip extends StatelessWidget {
  const _EtaChip({required this.scale, required this.minutes});

  final double scale;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$minutes min',
        style: OnboardingTypography.label(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
          color: OnboardingTheme.orange,
        ),
      ),
    );
  }
}

class _FloatingInfoCard extends StatelessWidget {
  const _FloatingInfoCard({required this.scale, required this.minutes});

  final double scale;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28 * scale,
            height: 28 * scale,
            decoration: BoxDecoration(
              color: OnboardingTheme.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              size: 16 * scale,
              color: OnboardingTheme.orange,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus 12',
                  style: OnboardingTypography.label(
                    fontSize: 12 * scale,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                Text(
                  '$minutes min away · Low crowding',
                  style: OnboardingTypography.body(
                    fontSize: 10 * scale,
                    color: const Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LightMapPainter extends CustomPainter {
  _LightMapPainter({
    required this.routeDraw,
    required this.busT,
    required this.route,
  });

  final double routeDraw;
  final double busT;
  final List<Offset> route;

  static const _mapBg = Color(0xFFF4F4F4);
  static const _building = Color(0xFFDADADA);
  static const _road = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _mapBg);

    _drawBlocks(canvas, size);
    _drawRoads(canvas, size);

    final points =
        route.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

    if (routeDraw > 0) {
      final path = _trimPath(points, routeDraw);
      canvas.drawPath(
        path,
        Paint()
          ..color = OnboardingTheme.orange.withValues(alpha: 0.25)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = OnboardingTheme.orange
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < points.length; i++) {
      final lit = busT > i / (points.length - 1);
      _drawStop(canvas, points[i], size, lit);
    }

    if (busT > 0) {
      final bus = _pointOnPolyline(points, busT);
      _drawBus(canvas, bus, size);
    }
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final paint = Paint()..color = _building;
    final blocks = [
      Rect.fromLTWH(size.width * 0.06, size.height * 0.08, size.width * 0.22, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.34, size.height * 0.06, size.width * 0.24, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.66, size.height * 0.05, size.width * 0.28, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.58, size.width * 0.2, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.68, size.height * 0.56, size.width * 0.24, size.height * 0.2),
    ];
    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(5)),
        paint,
      );
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    final paint = Paint()..color = _road;
    final roads = [
      Rect.fromLTWH(size.width * 0.28, size.height * 0.04, size.width * 0.05, size.height * 0.88),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.04, size.width * 0.04, size.height * 0.88),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.42, size.width * 0.92, size.height * 0.04),
      Rect.fromLTWH(size.width * 0.04, size.height * 0.74, size.width * 0.92, size.height * 0.04),
    ];
    for (final road in roads) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(road, const Radius.circular(3)),
        paint,
      );
    }
  }

  void _drawStop(Canvas canvas, Offset center, Size size, bool lit) {
    final r = size.width * 0.018;
    canvas.drawCircle(
      center,
      r * (lit ? 1.35 : 1),
      Paint()
        ..color = lit
            ? OnboardingTheme.orange.withValues(alpha: 0.18)
            : Colors.transparent,
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = lit ? OnboardingTheme.orange : const Color(0xFFAEAEB2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      r * 0.45,
      Paint()..color = Colors.white,
    );
  }

  void _drawBus(Canvas canvas, Offset center, Size size) {
    final w = size.width * 0.028;
    canvas.drawCircle(
      center,
      w,
      Paint()..color = OnboardingTheme.orange,
    );
    canvas.drawCircle(
      center,
      w,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Path _trimPath(List<Offset> points, double t) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    var total = 0.0;
    final lengths = <double>[];
    for (var i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      lengths.add(len);
      total += len;
    }
    if (total == 0) return path;

    final target = total * t;
    var walked = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      final len = lengths[i];
      if (walked + len >= target) {
        final end = Offset.lerp(
          points[i],
          points[i + 1],
          ((target - walked) / len).clamp(0.0, 1.0),
        )!;
        path.lineTo(end.dx, end.dy);
        break;
      }
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
      walked += len;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _LightMapPainter oldDelegate) {
    return oldDelegate.routeDraw != routeDraw || oldDelegate.busT != busT;
  }
}

Offset _pointOnPolyline(List<Offset> points, double t) {
  var total = 0.0;
  final lengths = <double>[];
  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    lengths.add(len);
    total += len;
  }
  if (total == 0) return points.first;

  final target = t * total;
  var walked = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = lengths[i];
    if (walked + len >= target) {
      return Offset.lerp(points[i], points[i + 1], (target - walked) / len)!;
    }
    walked += len;
  }
  return points.last;
}
