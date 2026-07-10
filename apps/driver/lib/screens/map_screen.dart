import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:tardadi_core/tardadi_core.dart';

import '../l10n/app_localizations.dart';
import '../models/crowd_level.dart';
import '../services/driver_api.dart';
import '../services/driver_prefs.dart';
import '../services/session_store.dart';
import '../ui/driver_design.dart';
import '../ui/platform_ui.dart';
import '../utils/arabic_display.dart';
import '../widgets/driver_route_map.dart';
import '../widgets/trip_options_panel.dart';
import 'settings_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  static const _startThresholdMeters = 1500.0;
  static const _enforceStartDistance = false;

  final _api = createDriverApi();
  late final AnimationController _radarController;
  Timer? _gpsTimer;
  Timer? _distanceTimer;
  bool _tripActive = false;
  bool _tripPanelOpen = false;
  bool _etaSheetExpanded = false;
  bool _onBreak = false;
  double _distanceKm = 40;
  double _offRouteMeters = 0;
  String _selectedVehicle = 'Bus';
  String _lastGps = '--';
  CrowdLevel _crowdLevel = CrowdLevel.medium;
  int _targetStopIndex = 0;
  bool _returnLeg = false;
  Position? _driverPosition;

  DriverSession get _session => SessionStore.instance.session!;
  List<StopModel> get _orderedStops {
    final stops = [..._session.stops];
    stops.sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
    return stops;
  }

  StopModel? get _targetStop =>
      _targetStopIndex < _orderedStops.length ? _orderedStops[_targetStopIndex] : null;

  GeoPoint? get _activeTarget {
    final stop = _targetStop;
    if (stop != null) {
      return GeoPoint(latitude: stop.latitude, longitude: stop.longitude);
    }
    final end = _session.route.toLocation;
    if (end != null) {
      return GeoPoint(latitude: end.latitude, longitude: end.longitude);
    }
    return null;
  }

  GeoPoint? get _driverGeoPoint => _driverPosition == null
      ? null
      : GeoPoint(
          latitude: _driverPosition!.latitude,
          longitude: _driverPosition!.longitude,
        );

  String _tripTitle(BuildContext context) {
    final routeName = _session.route.name.trim();
    if (routeName.isNotEmpty) {
      return context.displayPlaceName(
        routeName,
        nameAr: _session.route.nameAr,
      );
    }
    return _session.bus.label;
  }

  Color get _routeColor => _colorFromHex(_session.route.colorHex);

  int get _etaMinutes {
    final target = _activeTarget;
    final position = _driverPosition;
    if (target == null) return 0;
    if (position == null) return 5;
    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      target.latitude,
      target.longitude,
    );
    final minutes = (meters / 1000) / 22 * 60;
    return minutes.clamp(1, 99).round();
  }

  bool get _isOffRoute => _offRouteMeters > 80;

  bool get _canStart =>
      !_enforceStartDistance || _distanceKm * 1000 <= _startThresholdMeters;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = SessionStore.instance.selectedVehicle ?? 'Bus';
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    unawaited(_refreshRouteDetail());
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

  Future<void> _refreshRouteDetail() async {
    final session = SessionStore.instance.session;
    if (session == null) return;
    if (session.route.polyline?.isNotEmpty == true &&
        session.route.fromLocation != null) {
      return;
    }

    try {
      final detail = await _api.getRoute(session.route.routeId);
      SessionStore.instance.updateRoute(detail.route, detail.stops);
      if (mounted) setState(() {});
    } catch (_) {
      // Keep session route when refresh fails.
    }
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
      final position = await _resolveDriverPosition();
      final target = _activeTarget;
      if (target == null) return;
      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        target.latitude,
        target.longitude,
      );
      if (mounted) {
        setState(() {
          _driverPosition = position;
          _distanceKm = (meters / 1000).clamp(0.0, 999);
          _offRouteMeters = _measureOffRoute(position);
        });
      }
    } catch (_) {
      // Keep the designed default distance when location is unavailable.
    }
  }

  double _measureOffRoute(Position position) {
    final routePoints = resolveRoutePoints(_session.route, _orderedStops);
    if (routePoints.isEmpty) return 0;
    return distanceToRouteMeters(
      routePoints,
      LatLng(position.latitude, position.longitude),
    );
  }

  static const _simulatorSnapThresholdMeters = 500.0;

  Future<Position> _resolveDriverPosition() async {
    final gps = await Geolocator.getCurrentPosition();
    if (!kDebugMode) return gps;

    final routePoints = resolveRoutePoints(_session.route, _orderedStops);
    if (routePoints.isEmpty) return gps;

    final offRoute = distanceToRouteMeters(
      routePoints,
      LatLng(gps.latitude, gps.longitude),
    );
    if (offRoute <= _simulatorSnapThresholdMeters) return gps;

    final start = resolveRouteStart(_session.route, _orderedStops);
    if (start == null) return gps;

    return Position(
      latitude: start.latitude,
      longitude: start.longitude,
      timestamp: DateTime.now(),
      accuracy: gps.accuracy,
      altitude: gps.altitude,
      altitudeAccuracy: gps.altitudeAccuracy,
      heading: gps.heading,
      headingAccuracy: gps.headingAccuracy,
      speed: gps.speed,
      speedAccuracy: gps.speedAccuracy,
    );
  }

  Future<void> _startTrip() async {
    if (_enforceStartDistance) {
      await _refreshDistance();
    }
    if (!mounted) return;
    if (!_canStart) {
      final l10n = context.l10n;
      _showError(
        l10n.cannotStartTrip(_formatDistance(context, _distanceKm)),
      );
      return;
    }

    try {
      final existingTripId = SessionStore.instance.session?.tripId;
      final tripId = existingTripId != null && existingTripId.isNotEmpty
          ? existingTripId
          : await _api.startTrip(
              driverId: _session.driver.driverId,
              busId: _session.bus.busId,
              routeId: _session.route.routeId,
            );
      if (existingTripId == null || existingTripId.isEmpty) {
        SessionStore.instance.updateTripId(tripId);
      }
      await _refreshDistance();
      setState(() {
        _tripActive = true;
        _tripPanelOpen = false;
        _onBreak = false;
        _targetStopIndex = 0;
        _returnLeg = false;
        _etaSheetExpanded = false;
      });
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
        _tripPanelOpen = false;
        _onBreak = false;
        _lastGps = '--';
        _targetStopIndex = 0;
        _returnLeg = false;
        _etaSheetExpanded = false;
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
    _gpsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final position = await _resolveDriverPosition();
        await _api.sendGps(
          tripId: tripId,
          driverId: _session.driver.driverId,
          busId: _session.bus.busId,
          latitude: position.latitude,
          longitude: position.longitude,
          speedKmh: position.speed * 3.6,
          heading: position.heading,
          crowdLevel: _crowdLevel.name,
        );
        if (mounted) {
          final target = _activeTarget;
          if (target == null) return;
          final meters = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            target.latitude,
            target.longitude,
          );
          setState(() {
            _driverPosition = position;
            _distanceKm = (meters / 1000).clamp(0.0, 999);
            _lastGps = TimeOfDay.now().format(context);
            _offRouteMeters = _measureOffRoute(position);
          });
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
            SessionStore.instance.setVehicle(vehicle);
            final driverKey = DriverPrefs.driverKey(
              phone: _session.driver.phone,
              driverId: _session.driver.driverId,
            );
            unawaited(
              DriverPrefs.instance.saveVehicleSetup(
                driverKey: driverKey,
                vehicle: vehicle,
              ),
            );
          },
          onLogout: () {
            _gpsTimer?.cancel();
            SessionStore.instance.clear();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          },
        ),
      ),
    );
  }

  Future<void> _confirmEndTrip() async {
    final l10n = context.l10n;
    final confirmed = await showPlatformConfirmDialog(
      context,
      title: l10n.endTripTitle,
      message: l10n.endTripMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.endTrip,
      isDestructive: true,
    );
    if (confirmed) {
      await _endTrip();
    }
  }

  void _toggleTripPanel() {
    setState(() {
      _tripPanelOpen = !_tripPanelOpen;
      if (_tripPanelOpen) _etaSheetExpanded = false;
    });
  }

  void _toggleEtaSheet() {
    if (_tripPanelOpen) return;
    setState(() => _etaSheetExpanded = !_etaSheetExpanded);
  }

  void _toggleBreak() {
    setState(() => _onBreak = !_onBreak);
    DriverSnack.show(
      context,
      _onBreak ? context.l10n.breakStarted : context.l10n.tripResumed,
    );
  }

  Future<void> _markArrived() async {
    final tripId = _session.tripId;
    if (tripId != null) {
      final stop = _targetStop;
      try {
        await _api.markTripArrived(
          tripId: tripId,
          driverId: _session.driver.driverId,
          stopId: stop?.stopId,
        );
      } catch (_) {}
    }

    if (!_returnLeg) {
      final reversedRoute = reverseRouteModel(_session.route);
      final reversedStops = reverseStops(_orderedStops);
      SessionStore.instance.updateRoute(reversedRoute, reversedStops);
      setState(() {
        _returnLeg = true;
        _targetStopIndex = 0;
        _etaSheetExpanded = false;
      });
      await _refreshDistance();
      if (!mounted) return;
      DriverSnack.show(context, context.l10n.returnRouteStarted);
      return;
    }

    await _confirmEndTrip();
  }

  Widget _buildIdleScaffold(DriverSession session) {
    final l10n = context.l10n;
    return DriverChrome(
      child: Column(
        children: [
          Container(
            color: DriverColors.navyPanel,
            padding: EdgeInsets.fromLTRB(
              42,
              MediaQuery.paddingOf(context).top + 34,
              28,
              18,
            ),
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
                Text(
                  l10n.tardadi,
                  style: const TextStyle(
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                48,
                64,
                48,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
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
                  Text(
                    l10n.distanceFromStart,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _formatDistance(context, _distanceKm),
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
                    label: l10n.start,
                    onPressed: _startTrip,
                    color: DriverColors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.lastGps(
                      gps: _lastGps,
                      route: context.displayPlaceName(
                        session.route.name,
                        nameAr: session.route.nameAr,
                      ),
                      vehicle: l10n.vehicleLabel(_selectedVehicle),
                    ),
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
        ],
      ),
    );
  }

  Widget _buildActiveTripScaffold() {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DriverChrome(
      bodyColor: DriverColors.navyDeep,
      child: Column(
        children: [
          Container(
            color: DriverColors.navyPanel,
            padding: EdgeInsets.fromLTRB(
              28,
              MediaQuery.paddingOf(context).top + 22,
              28,
              18,
            ),
            child: Row(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    DriverAssets.mark,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    _tripTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (!_tripPanelOpen)
                  const Positioned.fill(
                    child: ColoredBox(color: DriverColors.navyDeep),
                  ),
                if (!_tripPanelOpen)
                  Positioned.fill(
                    child: DriverRouteMap(
                      route: _session.route,
                      stops: _orderedStops,
                      routeColor: _routeColor,
                      targetStopIndex: _targetStopIndex,
                      driverPosition: _driverGeoPoint,
                      driverHeading: _driverPosition?.heading,
                      followDriver: _tripActive && !_onBreak,
                    ),
                  ),
                if (_isOffRoute && !_tripPanelOpen)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: DriverColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.offRoute,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                DriverLeftSlidePanel(
                  visible: _tripPanelOpen,
                  onClose: _toggleTripPanel,
                  child: TripOptionsPanel(
                    crowdLevel: _crowdLevel,
                    onCrowdLevelChanged: (level) =>
                        setState(() => _crowdLevel = level),
                    onEndTrip: _confirmEndTrip,
                    onBreak: _toggleBreak,
                    onBreakLabel:
                        _onBreak ? l10n.resumeTrip : l10n.takeABreak,
                  ),
                ),
              ],
            ),
          ),
          if (!_tripPanelOpen)
            _TripSummarySheet(
              etaMinutes: _etaMinutes,
              expanded: _etaSheetExpanded,
              bottomInset: bottomInset,
              onBreak: _onBreak,
              onSheetTap: _toggleEtaSheet,
              onPanelTap: _toggleTripPanel,
              onArrived: _markArrived,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance.session;
    if (session == null) {
      return const Scaffold(body: Center(child: Text('لا توجد جلسة')));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: _tripActive
          ? KeyedSubtree(
              key: const ValueKey('active-trip'),
              child: _buildActiveTripScaffold(),
            )
          : KeyedSubtree(
              key: const ValueKey('idle-trip'),
              child: _buildIdleScaffold(session),
            ),
    );
  }
}

String _formatDistance(BuildContext context, double kilometers) {
  return context.l10n.formatDistanceKm(kilometers);
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
            canStart ? context.l10n.youCanStart : context.l10n.goCloserToStart,
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

Color _colorFromHex(String value) {
  final normalized = value.replaceAll('#', '').trim();
  if (normalized.length == 6) {
    return Color(int.parse('FF$normalized', radix: 16));
  }
  if (normalized.length == 8) {
    return Color(int.parse(normalized, radix: 16));
  }
  return DriverColors.orange;
}

class _TripSummarySheet extends StatelessWidget {
  const _TripSummarySheet({
    required this.etaMinutes,
    required this.expanded,
    required this.bottomInset,
    required this.onBreak,
    required this.onSheetTap,
    required this.onPanelTap,
    required this.onArrived,
  });

  final int etaMinutes;
  final bool expanded;
  final double bottomInset;
  final bool onBreak;
  final VoidCallback onSheetTap;
  final VoidCallback onPanelTap;
  final VoidCallback onArrived;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = onBreak ? l10n.onBreak : l10n.minutesEta(etaMinutes);
    final subtitle =
        onBreak ? l10n.tripPaused : l10n.estimatedArrival;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: DriverColors.navyDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 10, 22, 18 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onSheetTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onPanelTap,
                      icon: const Icon(
                        Icons.segment_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              if (expanded && !onBreak) ...[
                const SizedBox(height: 10),
                Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
                const SizedBox(height: 18),
                _SwipeArrivedButton(onCompleted: onArrived),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeArrivedButton extends StatefulWidget {
  const _SwipeArrivedButton({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_SwipeArrivedButton> createState() => _SwipeArrivedButtonState();
}

class _SwipeArrivedButtonState extends State<_SwipeArrivedButton> {
  static const _thumbSize = 62.0;
  static const _trackHeight = 62.0;

  double _dragOffset = 0;
  bool _completed = false;

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (_completed) return;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final delta = isRtl ? -details.delta.dx : details.delta.dx;
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(0, maxDrag);
    });
  }

  void _onDragEnd(double maxDrag) {
    if (_completed) return;
    if (_dragOffset >= maxDrag * 0.82) {
      setState(() {
        _dragOffset = maxDrag;
        _completed = true;
      });
      widget.onCompleted();
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _dragOffset = 0;
          _completed = false;
        });
      });
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag =
            (constraints.maxWidth - _thumbSize).clamp(0.0, double.infinity);
        final progress = maxDrag == 0 ? 0.0 : (_dragOffset / maxDrag).clamp(0.0, 1.0);
        final fillWidth = (_dragOffset + _thumbSize).clamp(_thumbSize, constraints.maxWidth);

        return SizedBox(
          height: _trackHeight,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Container(
                height: _trackHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF7577A2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _completed ? l10n.confirmed : l10n.arrived,
                  style: TextStyle(
                    color: progress > 0.55
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.92),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: fillWidth / constraints.maxWidth,
                  child: Container(
                    height: _trackHeight,
                    color: DriverColors.orange,
                  ),
                ),
              ),
              PositionedDirectional(
                start: _dragOffset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (_) => _onDragEnd(maxDrag),
                  child: Container(
                    width: _thumbSize,
                    height: _trackHeight,
                    decoration: BoxDecoration(
                      color: DriverColors.orange,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    final headCenter = Offset(center.dx, center.dy - 10);
    const headRadius = 22.0;

    // Pin tail
    final tail = Path()
      ..moveTo(headCenter.dx - 14, headCenter.dy + 10)
      ..lineTo(headCenter.dx, center.dy + 34)
      ..lineTo(headCenter.dx + 14, headCenter.dy + 10)
      ..close();
    canvas.drawPath(tail, pinPaint);

    // Pin head
    canvas.drawCircle(headCenter, headRadius, pinPaint);

    // Inner hole (white, like map pin)
    canvas.drawCircle(
      headCenter,
      9,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
