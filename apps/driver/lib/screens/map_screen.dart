import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../services/driver_api.dart';
import '../services/session_store.dart';
import '../ui/driver_design.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  static const _startThresholdMeters = 1500.0;

  final _api = createDriverApi();
  late final AnimationController _radarController;
  Timer? _gpsTimer;
  Timer? _distanceTimer;
  bool _tripActive = false;
  double _distanceKm = 40;
  String _selectedVehicle = 'Bus';
  String _lastGps = '--';

  DriverSession get _session => SessionStore.instance.session!;
  bool get _canStart => _distanceKm * 1000 <= _startThresholdMeters;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _refreshDistance();
    _distanceTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshDistance(),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    _gpsTimer?.cancel();
    _distanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshDistance() async {
    final session = SessionStore.instance.session;
    if (session == null || session.stops.isEmpty) return;

    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final firstStop = session.stops.first;
      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        firstStop.latitude,
        firstStop.longitude,
      );
      if (mounted) {
        setState(() => _distanceKm = (meters / 1000).clamp(0.1, 999));
      }
    } catch (_) {
      // Keep the designed default distance when location is unavailable.
    }
  }

  Future<void> _startTrip() async {
    await _refreshDistance();
    if (!_canStart) {
      _showError(
        'لا يمكن بدء الرحلة الآن. اقترب من نقطة البداية (${_formatDistance(_distanceKm)} متبقية).',
      );
      return;
    }

    try {
      final tripId = await _api.startTrip(
        driverId: _session.driver.driverId,
        busId: _session.bus.busId,
        routeId: _session.route.routeId,
      );
      SessionStore.instance.updateTripId(tripId);
      setState(() => _tripActive = true);
      await _startGps(tripId);
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _endTrip() async {
    final tripId = SessionStore.instance.session?.tripId;
    if (tripId == null) return;

    try {
      await _api.endTrip(tripId: tripId, driverId: _session.driver.driverId);
      _gpsTimer?.cancel();
      SessionStore.instance.updateTripId(null);
      setState(() {
        _tripActive = false;
        _lastGps = '--';
      });
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _startGps(String tripId) async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showError('يجب السماح بالموقع لإرسال موقع الباص');
      return;
    }

    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        await _api.sendGps(
          tripId: tripId,
          driverId: _session.driver.driverId,
          busId: _session.bus.busId,
          latitude: position.latitude,
          longitude: position.longitude,
          speedKmh: position.speed * 3.6,
          heading: position.heading,
        );
        if (mounted) {
          setState(() => _lastGps = TimeOfDay.now().format(context));
        }
      } catch (_) {}
    });
  }

  void _showError(String message) {
    DriverSnack.show(context, message);
  }

  void _openSettings() {
    Navigator.of(context).push(
      driverRoute(
        beginOffset: const Offset(0.12, 0),
        builder: (_) => SettingsScreen(
          session: _session,
          selectedVehicle: _selectedVehicle,
          onVehicleChanged: (vehicle) {
            setState(() => _selectedVehicle = vehicle);
          },
          onLogout: () {
            _gpsTimer?.cancel();
            SessionStore.instance.clear();
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          },
        ),
      ),
    );
  }

  void _blockedStart() {
    _showError(
      'اقترب من نقطة البداية أولاً. المسافة الحالية ${_formatDistance(_distanceKm)}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance.session;
    if (session == null) {
      return const Scaffold(body: Center(child: Text('لا توجد جلسة')));
    }

    return Scaffold(
      backgroundColor: DriverColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(42, 34, 28, 18),
              child: Row(
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      DriverAssets.mark,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Tardadi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _openSettings,
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: DriverColors.navyDeep,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 64, 48, 64),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 196,
                        height: 196,
                        child: AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RadarPainter(
                                rotation: _radarController.value * math.pi * 2,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 46),
                      const Text(
                        'Your distance from starting point',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _formatDistance(_distanceKm),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _StatusPill(canStart: _canStart),
                      const Spacer(),
                      DriverButton(
                        label: _tripActive ? 'End trip' : 'Start',
                        onPressed: _tripActive
                            ? _endTrip
                            : (_canStart ? _startTrip : _blockedStart),
                        color: _tripActive
                            ? Colors.red.shade700
                            : (_canStart
                                  ? const Color(0xFFAE3E35)
                                  : DriverColors.card),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Last GPS: $_lastGps • ${session.route.name} • ${session.bus.label}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.48),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDistance(double kilometers) {
  if (kilometers < 1) {
    return '${(kilometers * 1000).round()} m';
  }

  return '${kilometers.round()} km';
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.canStart});

  final bool canStart;

  @override
  Widget build(BuildContext context) {
    final color = canStart ? DriverColors.green : DriverColors.orange;
    return Container(
      width: 244,
      height: 38,
      decoration: BoxDecoration(
        color: canStart ? const Color(0xFF244C50) : const Color(0xFF5E5480),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            canStart ? 'You can start' : 'Go closer to start',
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.28);

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, ringPaint);
    }

    final axisPaint = Paint()
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.14);
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      axisPaint,
    );

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF5D91FF).withValues(alpha: 0),
          const Color(0xFF5D91FF).withValues(alpha: 0.72),
        ],
        stops: const [0.08, 1],
        transform: const GradientRotation(math.pi / 2),
      ).createShader(Offset.zero & size);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.95),
      0,
      math.pi / 2,
      true,
      sweepPaint,
    );
    canvas.restore();

    final pinPaint = Paint()..color = DriverColors.orange;
    final path = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(center.dx, center.dy - 11), radius: 24),
      )
      ..moveTo(center.dx - 18, center.dy + 5)
      ..lineTo(center.dx, center.dy + 36)
      ..lineTo(center.dx + 18, center.dy + 5)
      ..close();
    canvas.drawPath(path, pinPaint);
    canvas.drawCircle(center, 6, Paint()..color = DriverColors.navyDeep);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
