import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class LocationIllustration extends StatefulWidget {
  const LocationIllustration({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

  @override
  State<LocationIllustration> createState() => _LocationIllustrationState();
}

class _LocationIllustrationState extends State<LocationIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _route = [
    Offset(0.14, 0.72),
    Offset(0.28, 0.58),
    Offset(0.46, 0.48),
    Offset(0.64, 0.38),
    Offset(0.82, 0.28),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(LocationIllustration oldWidget) {
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

  int _etaMinutes(double progress) {
    final countdown = (1 - ((progress - 0.35) / 0.45).clamp(0.0, 1.0)) * 5;
    return countdown.ceil().clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value);
          final routeDraw = (progress / 0.32).clamp(0.0, 1.0);
          final busProgress = ((progress - 0.28) / 0.52).clamp(0.0, 1.0);
          final etaVisible = progress > 0.38;
          final etaMinutes = _etaMinutes(progress);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _LiveTrackingPainter(
                  progress: progress,
                  routeDraw: routeDraw,
                  busProgress: busProgress,
                  route: _route,
                ),
                child: const SizedBox.expand(),
              ),
              if (etaVisible)
                Positioned(
                  right: widget.width * 0.08,
                  top: widget.height * 0.1,
                  child: _EtaBadge(minutes: etaMinutes, visible: etaVisible),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EtaBadge extends StatelessWidget {
  const _EtaBadge({required this.minutes, required this.visible});

  final int minutes;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: OnboardingTheme.motionFast,
      child: AnimatedScale(
        scale: visible ? 1 : 0.92,
        duration: OnboardingTheme.motionMedium,
        curve: OnboardingTheme.motionCurve,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: OnboardingTheme.background.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: OnboardingTheme.orange.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: OnboardingTheme.orange.withValues(alpha: 0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes',
                style: const TextStyle(
                  color: OnboardingTheme.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'min',
                style: TextStyle(
                  color: OnboardingTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveTrackingPainter extends CustomPainter {
  const _LiveTrackingPainter({
    required this.progress,
    required this.routeDraw,
    required this.busProgress,
    required this.route,
  });

  final double progress;
  final double routeDraw;
  final double busProgress;
  final List<Offset> route;

  static const _blockColor = Color(0xFF1E2A5A);
  static const _streetColor = Color(0xFF263366);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = OnboardingTheme.card,
    );

    _drawAmbientGlow(canvas, size);
    _drawCity(canvas, size);
    _drawRoute(canvas, size);
    _drawLivePulse(canvas, size);

    final points = route.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final busPoint = _pointOnPolyline(points, busProgress);

    if (busProgress > 0) {
      _drawBus(canvas, busPoint, size, _segmentAngleAt(points, busProgress));
    }

    _drawDestinationStop(canvas, points.last, size);
  }

  void _drawAmbientGlow(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          OnboardingTheme.orange.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.72, size.height * 0.28),
          radius: size.width * 0.45,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawCity(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = _blockColor;
    final streetPaint = Paint()..color = _streetColor;

    final blocks = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.08, size.width * 0.22, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.34, size.height * 0.06, size.width * 0.24, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.66, size.height * 0.05, size.width * 0.28, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.58, size.width * 0.2, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.68, size.height * 0.58, size.width * 0.24, size.height * 0.2),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(7)),
        blockPaint,
      );
    }

    final streets = [
      Rect.fromLTWH(size.width * 0.28, size.height * 0.05, size.width * 0.05, size.height * 0.88),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.05, size.width * 0.04, size.height * 0.88),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.42, size.width * 0.9, size.height * 0.045),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.78, size.width * 0.9, size.height * 0.045),
    ];

    for (final street in streets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(street, const Radius.circular(4)),
        streetPaint,
      );
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (routeDraw <= 0) return;

    final points = route.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final path = _trimmedPolylinePath(points, routeDraw);

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.18)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (busProgress > 0) {
      canvas.drawPath(
        _trimmedPolylinePath(points, busProgress),
        Paint()
          ..color = OnboardingTheme.orange.withValues(alpha: 0.35)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawLivePulse(Canvas canvas, Size size) {
    if (progress < 0.2) return;

    final pulse = (math.sin(progress * math.pi * 3) + 1) / 2;
    final center = Offset(size.width * 0.14, size.height * 0.72);

    canvas.drawCircle(
      center,
      size.width * (0.06 + pulse * 0.015),
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.12 + pulse * 0.08)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawDestinationStop(Canvas canvas, Offset center, Size size) {
    final pulse = progress > 0.7
        ? 0.4 + math.sin(progress * math.pi * 5) * 0.12
        : 0.0;

    canvas.drawCircle(
      center,
      size.width * 0.07 * (1 + pulse),
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      size.width * 0.042,
      Paint()
        ..color = OnboardingTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawCircle(
      center,
      size.width * 0.018,
      Paint()..color = Colors.white,
    );
  }

  void _drawBus(Canvas canvas, Offset center, Size size, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle + math.pi / 2);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.11,
      height: size.width * 0.11,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.028));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = OnboardingTheme.orange
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(rrect, Paint()..color = OnboardingTheme.orange);

    final icon = Icons.directions_bus_rounded;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.055,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  Path _trimmedPolylinePath(List<Offset> points, double t) {
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
  bool shouldRepaint(covariant _LiveTrackingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.routeDraw != routeDraw ||
        oldDelegate.busProgress != busProgress;
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

double _segmentAngleAt(List<Offset> points, double t) {
  var total = 0.0;
  final lengths = <double>[];

  for (var i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    lengths.add(len);
    total += len;
  }

  if (total == 0) return 0;

  final target = t * total;
  var walked = 0.0;

  for (var i = 0; i < points.length - 1; i++) {
    final len = lengths[i];
    if (walked + len >= target) {
      final delta = points[i + 1] - points[i];
      return math.atan2(delta.dy, delta.dx);
    }
    walked += len;
  }

  return 0;
}
