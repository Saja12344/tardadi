import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tardadi_core/tardadi_core.dart';

class PassengerRouteMap extends StatefulWidget {
  const PassengerRouteMap({
    super.key,
    required this.route,
    required this.stops,
    required this.buses,
    this.borderRadius = 16,
  });

  final RouteModel route;
  final List<StopModel> stops;
  final List<BusModel> buses;
  final double borderRadius;

  @override
  State<PassengerRouteMap> createState() => _PassengerRouteMapState();
}

class _PassengerRouteMapState extends State<PassengerRouteMap> {
  final _mapController = MapController();

  @override
  void didUpdateWidget(covariant PassengerRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fitRoute();
  }

  void _fitRoute() {
    final points = _allPoints();
    final bounds = _boundsForPoints(points);
    if (bounds == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
      );
    });
  }

  List<LatLng> _allPoints() {
    final points = resolveRoutePoints(widget.route, widget.stops);
    for (final bus in widget.buses) {
      final location = bus.currentLocation;
      if (location != null) {
        points.add(LatLng(location.latitude, location.longitude));
      }
    }
    return points;
  }

  LatLngBounds? _boundsForPoints(List<LatLng> points) {
    if (points.isEmpty) return null;
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  Color _routeColor() {
    final hex = widget.route.colorHex.replaceAll('#', '').trim();
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return const Color(0xFFEB4F26);
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = resolveRoutePoints(widget.route, widget.stops);
    final initialCenter = routePoints.isNotEmpty
        ? routePoints.first
        : const LatLng(24.7136, 46.6753);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
          onMapReady: _fitRoute,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.tardadi.tardadiPassenger',
          ),
          if (routePoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: _routeColor(),
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  strokeJoin: StrokeJoin.round,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              ..._stopMarkers(),
              ..._busMarkers(),
            ],
          ),
        ],
      ),
    );
  }

  List<Marker> _stopMarkers() {
    return [
      for (final stop in widget.stops)
        Marker(
          point: LatLng(stop.latitude, stop.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF87171),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${stop.sequenceNo}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
    ];
  }

  List<Marker> _busMarkers() {
    return [
      for (final bus in widget.buses)
        if (bus.currentLocation != null)
          Marker(
            point: LatLng(
              bus.currentLocation!.latitude,
              bus.currentLocation!.longitude,
            ),
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (bus.isLive ? const Color(0xFF4ADE80) : Colors.grey)
                        .withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: bus.isLive
                        ? const Color(0xFF4285F4)
                        : Colors.grey.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ],
            ),
          ),
    ];
  }
}
