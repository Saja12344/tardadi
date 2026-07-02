import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({
    super.key,
    required this.onAllowOnce,
    required this.onAllowWhileUsing,
    required this.onDeny,
  });

  final VoidCallback onAllowOnce;
  final VoidCallback onAllowWhileUsing;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _PermissionIcon(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.locationPermissionTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.locationPermissionBody,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MapPreview(preciseLabel: l10n.preciseOn),
                    const SizedBox(height: 16),
                    _DialogButton(
                      label: l10n.allowOnce,
                      onPressed: onAllowOnce,
                    ),
                    const SizedBox(height: 8),
                    _DialogButton(
                      label: l10n.allowWhileUsingApp,
                      onPressed: onAllowWhileUsing,
                    ),
                    const SizedBox(height: 8),
                    _DialogButton(
                      label: l10n.dontAllow,
                      onPressed: onDeny,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 28),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.back_hand, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.preciseLabel});

  final String preciseLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          children: [
            CustomPaint(
              painter: _MiniMapPainter(),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.navigation, size: 14, color: Color(0xFF007AFF)),
                    const SizedBox(width: 4),
                    Text(
                      preciseLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0.1, 0.15),
              child: Icon(Icons.circle, size: 18, color: Color(0xFF007AFF)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFECEAE4),
    );

    final block = Paint()..color = const Color(0xFFF7F5EF);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * size.width / 3 + 8,
              row * size.height / 4 + 8,
              size.width / 3 - 16,
              size.height / 4 - 16,
            ),
            const Radius.circular(8),
          ),
          block,
        );
      }
    }

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      road,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.65),
          foregroundColor: const Color(0xFF007AFF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
