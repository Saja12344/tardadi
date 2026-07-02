import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _LocationIllustrationPainter(progress: _controller.value),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _LocationIllustrationPainter extends CustomPainter {
  const _LocationIllustrationPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = OnboardingTheme.card,
    );

    final center = Offset(size.width * 0.5, size.height * 0.52);

    for (var i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = size.width * (0.18 + ringProgress * 0.28);
      final opacity = (1 - ringProgress) * 0.35;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = OnboardingTheme.orange.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    final crossPaint = Paint()
      ..color = OnboardingTheme.orange.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx, size.height * 0.08),
      Offset(center.dx, size.height * 0.96),
      crossPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, center.dy),
      Offset(size.width * 0.92, center.dy),
      crossPaint,
    );

    _drawStopCard(
      canvas,
      Offset(size.width * 0.12, size.height * 0.28),
      math.sin(progress * math.pi * 2) * 3,
    );
    _drawStopCard(
      canvas,
      Offset(size.width * 0.58, size.height * 0.16),
      math.sin((progress + 0.33) * math.pi * 2) * 3,
    );
    _drawStopCard(
      canvas,
      Offset(size.width * 0.62, size.height * 0.72),
      math.sin((progress + 0.66) * math.pi * 2) * 3,
    );

    _drawPin(canvas, center);
  }

  void _drawStopCard(Canvas canvas, Offset origin, double bob) {
    final shifted = origin.translate(0, bob);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(shifted.dx, shifted.dy, 88, 34),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = OnboardingTheme.background);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = OnboardingTheme.orange.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shifted.dx + 8, shifted.dy + 8, 12, 18),
        const Radius.circular(3),
      ),
      Paint()..color = OnboardingTheme.orange,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shifted.dx + 26, shifted.dy + 10, 48, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6E7AA8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shifted.dx + 26, shifted.dy + 20, 36, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF556099),
    );
  }

  void _drawPin(Canvas canvas, Offset center) {
    final pinPaint = Paint()..color = OnboardingTheme.orange;
    final path = Path()
      ..moveTo(center.dx, center.dy + 28)
      ..quadraticBezierTo(
        center.dx - 24,
        center.dy - 4,
        center.dx,
        center.dy - 28,
      )
      ..quadraticBezierTo(
        center.dx + 24,
        center.dy - 4,
        center.dx,
        center.dy + 28,
      )
      ..close();
    canvas.drawPath(path, pinPaint);
    canvas.drawCircle(
      Offset(center.dx, center.dy - 10),
      10,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _LocationIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
