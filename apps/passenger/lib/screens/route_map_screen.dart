import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/route_list_item.dart';
import '../services/bus_arrival_notifications.dart';
import '../widgets/left_back_button.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/vehicle_icon.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key, required this.route});

  final RouteListItem route;

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _notifications = BusArrivalNotificationService.instance;
  late final List<BusArrivalItem> _buses;

  @override
  void initState() {
    super.initState();
    _buses = BusArrivalItem.demoForRoute(widget.route.name);
    _notifications.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notifications.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleBell(BusArrivalItem bus) async {
    await _notifications.toggle(
      busId: bus.id,
      busName: bus.name,
      routeId: widget.route.routeId,
      initialMinutes: bus.minutesAway,
    );
  }

  void _openFullMap() {
    final l10n = context.l10n;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullRouteMapScreen(
          title: l10n.routeStopTitle(widget.route.name, 'A'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      appBar: LeftBackAppBar(
        backgroundColor: OnboardingTheme.background,
        onBack: () => Navigator.of(context).pop(),
        title: Text(
          l10n.routeStopTitle(widget.route.name, 'A'),
          style: const TextStyle(
            color: OnboardingTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _RouteMapPreview(onTap: _openFullMap),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: OnboardingTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                itemCount: _buses.length,
                itemBuilder: (context, index) {
                  final bus = _buses[index];
                  return _BusArrivalCard(
                    index: index,
                    item: bus,
                    notificationsEnabled: _notifications.isEnabled(bus.id),
                    onToggleNotifications: () => _toggleBell(bus),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullRouteMapScreen extends StatelessWidget {
  const _FullRouteMapScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      appBar: LeftBackAppBar(
        backgroundColor: OnboardingTheme.background,
        onBack: () => Navigator.of(context).pop(),
        title: Text(
          title,
          style: const TextStyle(
            color: OnboardingTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: _RouteMapCanvas(borderRadius: 16),
      ),
    );
  }
}

class _RouteMapPreview extends StatelessWidget {
  const _RouteMapPreview({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _RouteMapCanvas(borderRadius: 16),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteMapCanvas extends StatelessWidget {
  const _RouteMapCanvas({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _RouteMapPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BusArrivalCard extends StatelessWidget {
  const _BusArrivalCard({
    required this.index,
    required this.item,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
  });

  final int index;
  final BusArrivalItem item;
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            VehicleIcon(
              vehicleType: item.vehicleType,
              color: OnboardingTheme.orange,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.vehicleLabel(item.vehicleType, item.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.minutesLabel(item.minutesAway)} · ${l10n.crowdingLabel(item.crowdingLabel)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ubuntu(
                      color: OnboardingTheme.muted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _NotificationBellButton(
              enabled: notificationsEnabled,
              onTap: onToggleNotifications,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            enabled ? Icons.notifications : Icons.notifications_outlined,
            color: enabled ? OnboardingTheme.orange : OnboardingTheme.muted,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8E4DC),
    );

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.75),
      road,
    );

    final stopA = Offset(size.width * 0.28, size.height * 0.32);
    final stopB = Offset(size.width * 0.72, size.height * 0.62);

    _drawDashedLine(canvas, stopA, stopB, const Color(0xFFE53935));

    _drawStop(canvas, stopA, 'A');
    _drawStop(canvas, stopB, 'B');
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashLength = 8.0;
    const gapLength = 6.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final delta = end - start;
    final distance = delta.distance;
    final direction = delta / distance;
    var drawn = 0.0;
    var drawDash = true;

    while (drawn < distance) {
      final segment = drawDash ? dashLength : gapLength;
      final next = math.min(drawn + segment, distance);
      if (drawDash) {
        canvas.drawLine(
          start + direction * drawn,
          start + direction * next,
          paint,
        );
      }
      drawn = next;
      drawDash = !drawDash;
    }
  }

  void _drawStop(Canvas canvas, Offset center, String label) {
    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFFE53935));
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
