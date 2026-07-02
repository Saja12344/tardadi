import 'package:flutter/material.dart';

import '../models/route_list_item.dart';

class VehicleIcon extends StatelessWidget {
  const VehicleIcon({
    super.key,
    required this.vehicleType,
    required this.color,
    this.size = 24,
  });

  final VehicleType vehicleType;
  final Color color;
  final double size;

  static IconData iconFor(VehicleType type) {
    return switch (type) {
      VehicleType.golfCar => Icons.electric_car,
      VehicleType.bus => Icons.directions_bus_filled,
      VehicleType.vanCar => Icons.airport_shuttle,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleType == VehicleType.golfCar) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GolfCartIconPainter(color: color),
        ),
      );
    }

    return Icon(iconFor(vehicleType), color: color, size: size);
  }
}

class _GolfCartIconPainter extends CustomPainter {
  const _GolfCartIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    canvas.drawCircle(Offset(w * 0.26, h * 0.82), w * 0.11, paint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.82), w * 0.11, paint);

    final body = Path()
      ..moveTo(w * 0.10, h * 0.72)
      ..lineTo(w * 0.10, h * 0.50)
      ..lineTo(w * 0.34, h * 0.34)
      ..lineTo(w * 0.78, h * 0.34)
      ..lineTo(w * 0.90, h * 0.44)
      ..lineTo(w * 0.90, h * 0.72)
      ..close();
    canvas.drawPath(body, paint);

    final roof = Path()
      ..moveTo(w * 0.20, h * 0.50)
      ..lineTo(w * 0.24, h * 0.24)
      ..lineTo(w * 0.76, h * 0.24)
      ..lineTo(w * 0.72, h * 0.34)
      ..lineTo(w * 0.34, h * 0.34)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.07
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawLine(
      Offset(w * 0.24, h * 0.24),
      Offset(w * 0.24, h * 0.50),
      Paint()
        ..color = color
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(w * 0.76, h * 0.24),
      Offset(w * 0.72, h * 0.34),
      Paint()
        ..color = color
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GolfCartIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
