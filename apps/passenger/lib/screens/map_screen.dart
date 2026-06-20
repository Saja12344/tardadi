import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tardadi_core/tardadi_core.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _api = TardadiApi(config: AppConfig.dev());
  List<RouteModel> _routes = [];
  List<BusModel> _buses = [];
  List<TripModel> _trips = [];
  String? _selectedRouteId;
  String _userLocation = '—';
  String? _loadError;
  DateTime? _lastUpdated;
  bool _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _loadUserLocation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _userLocation = 'فعّل خدمة الموقع');
      return;
    }

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() => _userLocation = 'لم يُسمح بالموقع');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userLocation =
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    });
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _api.getRoutes(),
        _api.getBuses(activeOnly: true),
        _api.getTrips(status: 'active'),
      ]);
      if (!mounted) return;
      setState(() {
        _routes = results[0] as List<RouteModel>;
        _buses = results[1] as List<BusModel>;
        _trips = results[2] as List<TripModel>;
        _loadError = null;
        _lastUpdated = DateTime.now();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  List<TripModel> get _filteredTrips {
    if (_selectedRouteId == null) return _trips;
    return _trips.where((t) => t.routeId == _selectedRouteId).toList();
  }

  List<BusModel> get _activeBuses {
    final tripBusIds = _filteredTrips.map((t) => t.busId).toSet();
    return _buses.where((b) => tripBusIds.contains(b.busId)).toList();
  }

  String? _routeNameForBus(BusModel bus) {
    final trip = _trips.where((t) => t.busId == bus.busId).firstOrNull;
    if (trip == null) return null;
    return _routes.where((r) => r.routeId == trip.routeId).firstOrNull?.name;
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return '—';
    final time = TimeOfDay.fromDateTime(_lastUpdated!);
    return time.format(context);
  }

  Future<void> _createReminder(BusModel bus) async {
    final trip = _trips.firstWhere(
      (t) => t.busId == bus.busId,
      orElse: () => throw Exception('لا توجد رحلة نشطة لهذا الباص'),
    );

    try {
      final routeData = await _api.getRoute(trip.routeId);
      final stop = routeData.stops.first;

      await _api.createReminder(
        userId: 'passenger-demo',
        busId: bus.busId,
        routeId: trip.routeId,
        stopId: stop.stopId,
        fcmToken: 'fcm-token-demo',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التذكير عند اقتراب ${bus.label} من ${stop.name}'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترددي'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: TardadiBrand.orange,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'خريطة الباصات',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              'موقعك: $_userLocation',
              style: const TextStyle(color: TardadiBrand.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: _selectedRouteId == null,
                  onTap: () => setState(() => _selectedRouteId = null),
                ),
                ..._routes.map(
                  (route) => _FilterChip(
                    label: route.name,
                    selected: _selectedRouteId == route.routeId,
                    onTap: () => setState(() => _selectedRouteId = route.routeId),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TardadiBrand.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🗺️ الخريطة',
                    style: TextStyle(
                      color: TardadiBrand.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _loading
                        ? 'جاري التحميل...'
                        : '${_activeBuses.length} باص نشط • ${_routes.length} خط',
                    style: const TextStyle(color: TardadiBrand.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'آخر تحديث: ${_formatLastUpdated()}',
                    style: const TextStyle(color: TardadiBrand.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  const Text(
                    'الخريطة الحقيقية ستُضاف لاحقاً',
                    style: TextStyle(color: TardadiBrand.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_loadError != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تعذّر الاتصال بالخادم',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loadError!,
                      style: const TextStyle(
                        color: TardadiBrand.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _loading = true);
                        _load();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'الباصات النشطة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_loading && _activeBuses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: TardadiBrand.orange),
                ),
              )
            else if (_activeBuses.isEmpty)
              const Text(
                'لا توجد باصات نشطة الآن',
                style: TextStyle(color: TardadiBrand.grey),
              )
            else
              ..._activeBuses.map((bus) {
                final location = bus.currentLocation;
                final routeName = _routeNameForBus(bus);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TardadiBrand.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (routeName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                routeName,
                                style: const TextStyle(
                                  color: TardadiBrand.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              location == null
                                  ? 'بانتظار GPS'
                                  : '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: TardadiBrand.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _createReminder(bus),
                        child: const Text('ذكّرني'),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: TardadiBrand.orange,
      labelStyle: TextStyle(
        color: selected ? TardadiBrand.white : TardadiBrand.white,
      ),
      backgroundColor: TardadiBrand.card,
    );
  }
}
