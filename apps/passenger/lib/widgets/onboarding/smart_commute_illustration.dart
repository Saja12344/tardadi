import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class SmartCommuteIllustration extends StatefulWidget {
  const SmartCommuteIllustration({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

  @override
  State<SmartCommuteIllustration> createState() =>
      _SmartCommuteIllustrationState();
}

class _SmartCommuteIllustrationState extends State<SmartCommuteIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _stopCenter = Offset(0.36, 0.62);
  static const _routeStart = Offset(0.12, 0.34);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(SmartCommuteIllustration oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOut.transform(_controller.value);
          final favoriteProgress = (progress / 0.28).clamp(0.0, 1.0);
          final notificationProgress =
              ((progress - 0.22) / 0.28).clamp(0.0, 1.0);
          final busProgress = ((progress - 0.48) / 0.4).clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _SmartCommutePainter(
                  progress: progress,
                  favoriteProgress: favoriteProgress,
                  busProgress: busProgress,
                ),
                child: const SizedBox.expand(),
              ),
              if (notificationProgress > 0)
                Positioned(
                  left: widget.width * 0.08,
                  right: widget.width * 0.08,
                  top: widget.height * 0.1 -
                      (1 - Curves.easeOutCubic.transform(notificationProgress)) *
                          24,
                  child: Opacity(
                    opacity: notificationProgress,
                    child: _NotificationCard(
                      width: widget.width,
                      progress: notificationProgress,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.width, required this.progress});

  final double width;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.94 + progress * 0.06,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.035,
        ),
        decoration: BoxDecoration(
          color: OnboardingTheme.background.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: OnboardingTheme.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.1,
              height: width * 0.1,
              decoration: BoxDecoration(
                color: OnboardingTheme.orange.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: OnboardingTheme.orange,
                size: width * 0.05,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bus arriving soon',
                    style: TextStyle(
                      color: OnboardingTheme.white,
                      fontSize: width * 0.038,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: width * 0.008),
                  Text(
                    'Route 24 · 2 min away',
                    style: TextStyle(
                      color: OnboardingTheme.muted,
                      fontSize: width * 0.032,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartCommutePainter extends CustomPainter {
  const _SmartCommutePainter({
    required this.progress,
    required this.favoriteProgress,
    required this.busProgress,
  });

  final double progress;
  final double favoriteProgress;
  final double busProgress;

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

    final stop = Offset(
      _SmartCommuteIllustrationState._stopCenter.dx * size.width,
      _SmartCommuteIllustrationState._stopCenter.dy * size.height,
    );
    final routeStart = Offset(
      _SmartCommuteIllustrationState._routeStart.dx * size.width,
      _SmartCommuteIllustrationState._routeStart.dy * size.height,
    );
    final routeEnd = stop;

    _drawRoute(canvas, routeStart, routeEnd, size, busProgress);
    _drawFavoriteStop(canvas, stop, size, favoriteProgress);

    if (busProgress > 0) {
      final busPoint = Offset.lerp(routeStart, routeEnd, busProgress)!;
      _drawBus(canvas, busPoint, size);
    }
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
          center: Offset(size.width * 0.36, size.height * 0.62),
          radius: size.width * 0.42,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawCity(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = _blockColor;
    final streetPaint = Paint()..color = _streetColor;

    final blocks = [
      Rect.fromLTWH(size.width * 0.06, size.height * 0.12, size.width * 0.24, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.1, size.width * 0.3, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.68, size.width * 0.3, size.height * 0.18),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(7)),
        blockPaint,
      );
    }

    final streets = [
      Rect.fromLTWH(size.width * 0.34, size.height * 0.08, size.width * 0.05, size.height * 0.84),
      Rect.fromLTWH(size.width * 0.52, size.height * 0.08, size.width * 0.04, size.height * 0.84),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.48, size.width * 0.86, size.height * 0.045),
    ];

    for (final street in streets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(street, const Radius.circular(4)),
        streetPaint,
      );
    }
  }

  void _drawRoute(
    Canvas canvas,
    Offset start,
    Offset end,
    Size size,
    double busT,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, end.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.16)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.85)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (busT > 0) {
      final metrics = path.computeMetrics().first;
      final extract = metrics.extractPath(0, metrics.length * busT);
      canvas.drawPath(
        extract,
        Paint()
          ..color = OnboardingTheme.orange.withValues(alpha: 0.35)
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawFavoriteStop(
    Canvas canvas,
    Offset center,
    Size size,
    double favoriteT,
  ) {
    final scale = 0.85 + favoriteT * 0.15;
    final ringRadius = size.width * 0.05 * scale;
    final glow = favoriteT > 0.5
        ? 0.25 + math.sin(progress * math.pi * 4) * 0.1
        : favoriteT * 0.25;

    canvas.drawCircle(
      center,
      ringRadius * 1.8,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: glow)
        ..style = PaintingStyle.fill,
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
      Paint()..color = Colors.white,
    );

    if (favoriteT > 0) {
      final starCenter = center + Offset(ringRadius * 0.95, -ringRadius * 1.1);
      _drawStar(canvas, starCenter, size.width * 0.028 * scale, favoriteT);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, double t) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 4 * math.pi / 5;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.25 * t)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTheme.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawBus(Canvas canvas, Offset center, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.11,
        height: size.width * 0.11,
      ),
      Radius.circular(size.width * 0.028),
    );

    canvas.drawRRect(
      rect,
      Paint()
        ..color = OnboardingTheme.orange
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(rect, Paint()..color = OnboardingTheme.orange);

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
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SmartCommutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.favoriteProgress != favoriteProgress ||
        oldDelegate.busProgress != busProgress;
  }
}
