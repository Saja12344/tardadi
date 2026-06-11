import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../services/session_store.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _api = TardadiApi();
  Timer? _gpsTimer;
  bool _tripActive = false;
  String _lastGps = '—';

  DriverSession get _session => SessionStore.instance.session!;

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  Future<void> _startTrip() async {
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
      _showError(error.toString());
    }
  }

  Future<void> _endTrip() async {
    final tripId = SessionStore.instance.session?.tripId;
    if (tripId == null) return;

    try {
      await _api.endTrip(
        tripId: tripId,
        driverId: _session.driver.driverId,
      );
      _gpsTimer?.cancel();
      SessionStore.instance.updateTripId(null);
      setState(() {
        _tripActive = false;
        _lastGps = '—';
      });
    } catch (error) {
      _showError(error.toString());
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance.session;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('لا توجد جلسة')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('خريطة السائق')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'الخط: ${session.route.name}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'الباص: ${session.bus.label}',
            style: const TextStyle(color: TardadiBrand.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TardadiBrand.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🗺️ الخط المسموح',
                  style: TextStyle(
                    color: TardadiBrand.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${session.stops.length} محطة على الخط',
                  style: const TextStyle(color: TardadiBrand.grey),
                ),
                const SizedBox(height: 12),
                ...session.stops.map(
                  (stop) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${stop.sequenceNo}. ${stop.name}'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'آخر إرسال GPS: $_lastGps',
            style: const TextStyle(color: TardadiBrand.grey),
          ),
          const SizedBox(height: 16),
          if (!_tripActive)
            ElevatedButton(
              onPressed: _startTrip,
              child: const Text('بدء الرحلة'),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: _endTrip,
              child: const Text('إنهاء الرحلة'),
            ),
        ],
      ),
    );
  }
}
