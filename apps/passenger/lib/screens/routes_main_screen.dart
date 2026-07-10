import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/route_list_item.dart';
import '../services/passenger_api.dart';
import '../services/user_session.dart';
import '../widgets/onboarding/onboarding_scale.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/route_card.dart';
import '../widgets/tardadi_brand_video.dart';
import '../widgets/settings_popup.dart';
import 'route_map_screen.dart';

class RoutesMainScreen extends StatefulWidget {
  const RoutesMainScreen({super.key});

  @override
  State<RoutesMainScreen> createState() => _RoutesMainScreenState();
}

class _RoutesMainScreenState extends State<RoutesMainScreen>
    with WidgetsBindingObserver {
  final _api = createPassengerApi();
  final _searchController = TextEditingController();
  List<RouteListItem> _routes = [];
  var _loading = true;
  String? _loadError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRoutes();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRoutes();
    }
  }

  Future<void> _loadRoutes({bool silent = false}) async {
    try {
      if (!silent && mounted) setState(() => _loading = true);
      final apiRoutes = await _api.getRoutes();
      if (!mounted) return;

      final activeRoutes = apiRoutes
          .where((route) => route.status == 'active')
          .map((route) => RouteListItem.fromRoute(route))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _routes = activeRoutes;
        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _routes = [];
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  List<RouteListItem> get _filteredRoutes {
    if (_query.isEmpty) return _routes;
    final l10n = context.l10n;
    return _routes
        .where((route) => l10n.routeNameMatchesQuery(route.name, _query))
        .toList();
  }

  List<RouteListItem> get _businessRoutes =>
      _filteredRoutes.where((route) => route.isBusiness).toList();

  List<RouteListItem> get _publicRoutes =>
      _filteredRoutes.where((route) => !route.isBusiness).toList();

  void _openRoute(RouteListItem route) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteMapScreen(route: route),
      ),
    );
  }

  void _openSettings() {
    SettingsPopup.show(context, onChanged: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final showBusiness = UserSession.instance.isBusiness;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: Stack(
        children: [
          const LogoWatermark(),
          SafeArea(
            child: Column(
              children: [
                _RoutesHeader(
                  scale: scale,
                  title: l10n.appName,
                  onMenuTap: _openSettings,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    scale.horizontalPadding,
                    scale.s(8),
                    scale.horizontalPadding,
                    scale.s(12),
                  ),
                  child: _SearchBar(
                    scale: scale,
                    controller: _searchController,
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: TardadiLoading(size: 80))
                      : _loadError != null
                          ? _ErrorState(
                              message: l10n.noRoutesFound,
                              onRetry: _loadRoutes,
                            )
                          : RefreshIndicator(
                              color: OnboardingTheme.orange,
                              onRefresh: () => _loadRoutes(silent: true),
                              child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                scale.s(20),
                                scale.s(8),
                                scale.s(20),
                                scale.s(28),
                              ),
                              children: [
                                if (showBusiness &&
                                    _businessRoutes.isNotEmpty) ...[
                                  _SectionHeader(
                                    title: l10n.business,
                                    scale: scale,
                                  ),
                                  ..._businessRoutes.map(
                                    (route) => _buildRouteCard(route, l10n),
                                  ),
                                  SizedBox(height: scale.s(8)),
                                ],
                                if (_publicRoutes.isNotEmpty) ...[
                                  _SectionHeader(
                                    title: l10n.publicSection,
                                    scale: scale,
                                  ),
                                  ..._publicRoutes.map(
                                    (route) => _buildRouteCard(route, l10n),
                                  ),
                                ],
                                if (_filteredRoutes.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: scale.s(56)),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: scale.s(48),
                                          color: OnboardingTheme.muted
                                              .withValues(alpha: 0.7),
                                        ),
                                        SizedBox(height: scale.s(12)),
                                        Text(
                                          l10n.noRoutesFound,
                                          style: GoogleFonts.ubuntu(
                                            color: OnboardingTheme.muted,
                                            fontSize: scale.s(15),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RouteListItem route, AppLocalizations l10n) {
    return RouteCard(
      name: l10n.localizeRouteName(route.name),
      frequencyLabel: l10n.localizeMetaLabel(route.frequencyLabel),
      busCountLabel: l10n.localizeMetaLabel(route.busCountLabel),
      stationsCountLabel: l10n.localizeMetaLabel(route.stationsCountLabel),
      onTap: () => _openRoute(route),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: OnboardingTheme.muted)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _RoutesHeader extends StatelessWidget {
  const _RoutesHeader({
    required this.scale,
    required this.title,
    required this.onMenuTap,
  });

  final OnboardingScale scale;
  final String title;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        scale.horizontalPadding,
        scale.s(8),
        scale.s(8),
        0,
      ),
      child: SizedBox(
        height: scale.s(52),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TardadiBrandVideo(size: scale.s(38)),
            ),
            Text(
              title,
              style: GoogleFonts.ubuntu(
                color: OnboardingTheme.white,
                fontSize: scale.s(28),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Material(
                color: Colors.white.withValues(alpha: 0.08),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onMenuTap,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(scale.s(10)),
                    child: Icon(
                      Icons.menu_rounded,
                      color: OnboardingTheme.white,
                      size: scale.s(22),
                    ),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.scale,
    required this.controller,
  });

  final OnboardingScale scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.24),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.ubuntu(
              color: OnboardingTheme.white,
              fontSize: scale.s(15),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: l10n.stationSearchHint,
              hintStyle: GoogleFonts.ubuntu(
                color: OnboardingTheme.white.withValues(alpha: 0.52),
                fontSize: scale.s(15),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: scale.s(22),
                color: OnboardingTheme.white.withValues(alpha: 0.72),
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(vertical: scale.s(14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: OnboardingTheme.orange.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.scale});

  final String title;
  final OnboardingScale scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: scale.s(14),
        top: scale.s(4),
      ),
      child: Row(
        children: [
          Container(
            width: scale.s(4),
            height: scale.s(22),
            decoration: BoxDecoration(
              color: OnboardingTheme.orange,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: scale.s(10)),
          Text(
            title,
            style: GoogleFonts.ubuntu(
              color: OnboardingTheme.white,
              fontSize: scale.s(22),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
