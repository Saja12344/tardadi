import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../l10n/app_localizations.dart';
import '../models/route_list_item.dart';
import '../services/bus_arrival_notifications.dart';
import '../services/passenger_api.dart';
import '../widgets/left_back_button.dart';
import '../widgets/onboarding/frosted_glass.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/passenger_route_map.dart';
import '../widgets/route_card.dart';
import '../widgets/tardadi_brand_video.dart';
import '../widgets/vehicle_icon.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key, required this.route});

  final RouteListItem route;

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _api = createPassengerApi();
  final _notifications = BusArrivalNotificationService.instance;
  RouteLiveSnapshot? _snapshot;
  List<BusArrivalItem> _buses = [];
  var _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _notifications.addListener(_onNotificationsChanged);
    _loadLive();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadLive());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _notifications.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLive() async {
    try {
      final snapshot = await _api.getRouteLive(widget.route.routeId);
      if (!mounted) return;
      final buses = snapshot.buses
          .map(
            (bus) => BusArrivalItem.fromBus(
              bus,
              minutesAway: _estimateMinutes(bus, snapshot.stops),
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _buses = buses;
        _loading = false;
      });
      _notifications.updateFromLive(buses: buses, stops: snapshot.stops);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int _estimateMinutes(BusModel bus, List<StopModel> stops) {
    final location = bus.currentLocation;
    if (location == null || stops.isEmpty) return 99;

    final target = stops.first;
    return estimateEtaMinutes(
      location,
      GeoPoint(latitude: target.latitude, longitude: target.longitude),
    );
  }

  Future<void> _toggleBell(BusArrivalItem bus) async {
    await _notifications.toggle(
      busId: bus.id,
      busName: bus.name,
      routeId: widget.route.routeId,
    );
  }

  void _openFullMap() {
    final snapshot = _snapshot;
    if (snapshot == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullRouteMapScreen(
          title: context.l10n.localizeRouteName(widget.route.name),
          route: snapshot.route,
          stops: snapshot.stops,
          buses: snapshot.buses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final snapshot = _snapshot;
    final routeName = l10n.localizeRouteName(widget.route.name);
    final liveCount = snapshot?.liveBusCount ?? widget.route.liveBusCount;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      appBar: LeftBackAppBar(
        backgroundColor: OnboardingTheme.background,
        onBack: () => Navigator.of(context).pop(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routeName,
              style: const TextStyle(
                color: OnboardingTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (liveCount > 0)
              Text(
                l10n.liveBusesOnRoute(liveCount),
                style: TextStyle(
                  color: OnboardingTheme.orange.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _loading || snapshot == null
                  ? const Center(child: TardadiLoading(size: 72))
                  : _RouteMapPreview(
                      onTap: _openFullMap,
                      child: PassengerRouteMap(
                        route: snapshot.route,
                        stops: snapshot.stops,
                        buses: snapshot.buses,
                        borderRadius: 16,
                      ),
                    ),
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
              child: Stack(
                children: [
                  const LogoWatermark(
                    opacity: 0.07,
                    alignment: Alignment(0, 0.15),
                  ),
                  _buses.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noLiveBuses,
                            style: GoogleFonts.ubuntu(
                              color: OnboardingTheme.muted,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                          itemCount: _buses.length,
                          itemBuilder: (context, index) {
                            final bus = _buses[index];
                            return _BusArrivalCard(
                              item: bus,
                              notificationsEnabled:
                                  _notifications.isEnabled(bus.id),
                              onToggleNotifications: () => _toggleBell(bus),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullRouteMapScreen extends StatelessWidget {
  const _FullRouteMapScreen({
    required this.title,
    required this.route,
    required this.stops,
    required this.buses,
  });

  final String title;
  final RouteModel route;
  final List<StopModel> stops;
  final List<BusModel> buses;

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: PassengerRouteMap(
          route: route,
          stops: stops,
          buses: buses,
          borderRadius: 16,
        ),
      ),
    );
  }
}

class _RouteMapPreview extends StatelessWidget {
  const _RouteMapPreview({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

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
              child,
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

class _BusArrivalCard extends StatelessWidget {
  const _BusArrivalCard({
    required this.item,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
  });

  final BusArrivalItem item;
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    const titleColor = OnboardingTheme.glassText;
    final chipTextColor = OnboardingTheme.white.withValues(alpha: 0.92);
    final chipIconColor = OnboardingTheme.white.withValues(alpha: 0.85);
    const iconBackground = Color.fromRGBO(255, 255, 255, 0.10);
    const iconBorder = Color.fromRGBO(255, 255, 255, 0.14);
    const chipBackground = Color.fromRGBO(255, 255, 255, 0.08);
    const chipBorder = Color.fromRGBO(255, 255, 255, 0.12);

    return FrostedGlass(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: iconBorder),
            ),
            alignment: Alignment.center,
            child: VehicleIcon(
              vehicleType: item.vehicleType,
              color: chipIconColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.vehicleLabel(item.vehicleType, item.name),
                        style: GoogleFonts.ubuntu(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (item.isLive) const _LiveBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ArrivalDetailChip(
                      icon: Icons.schedule_rounded,
                      label: l10n.minutesLabel(item.minutesAway),
                      textColor: chipTextColor,
                      iconColor: chipIconColor,
                      backgroundColor: chipBackground,
                      borderColor: chipBorder,
                    ),
                    _ArrivalDetailChip(
                      icon: Icons.groups_2_rounded,
                      label: l10n.crowdingLabel(item.crowdingLabel),
                      textColor: chipTextColor,
                      iconColor: chipIconColor,
                      backgroundColor: chipBackground,
                      borderColor: chipBorder,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _NotificationBellButton(
            enabled: notificationsEnabled,
            onTap: onToggleNotifications,
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OnboardingTheme.orange.withValues(alpha: 0.95),
            OnboardingTheme.orange.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: OnboardingTheme.orange.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.liveBadge,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalDetailChip extends StatelessWidget {
  const _ArrivalDetailChip({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.ubuntu(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled
                ? OnboardingTheme.orange
                : OnboardingTheme.background.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? OnboardingTheme.orange
                  : OnboardingTheme.muted.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Icon(
            enabled ? Icons.notifications : Icons.notifications_outlined,
            color: enabled ? Colors.white : OnboardingTheme.muted,
            size: 22,
          ),
        ),
      ),
    );
  }
}
