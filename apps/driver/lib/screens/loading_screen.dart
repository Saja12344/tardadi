import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../services/driver_prefs.dart';
import '../services/session_store.dart';
import '../ui/driver_design.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';

/// Splash shown on cold start (loding.png).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        driverRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _BrandSplash();
  }
}

/// Brief loader after OTP success, before home or first-time vehicle pick.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.session});

  final DriverSession session;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    SessionStore.instance.set(widget.session);
    unawaited(_continueAfterLoad());
  }

  Future<void> _continueAfterLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final driverKey = DriverPrefs.driverKey(
      phone: widget.session.driver.phone,
      driverId: widget.session.driver.driverId,
    );
    final prefs = DriverPrefs.instance;
    final savedVehicle = await prefs.getSelectedVehicle(driverKey);
    if (savedVehicle != null) {
      SessionStore.instance.setVehicle(savedVehicle);
    }

    final isFirstLogin = !await prefs.hasCompletedVehicleSetup(driverKey);
    final hasActiveTrip = (widget.session.tripId?.isNotEmpty ?? false);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      driverRoute(
        builder: (_) => (isFirstLogin && !hasActiveTrip)
            ? const VehicleOnboardingScreen()
            : const MapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _BrandSplash();
  }
}

class _BrandSplash extends StatelessWidget {
  const _BrandSplash();

  @override
  Widget build(BuildContext context) {
    return const DriverChrome(child: _BrandSplashBody());
  }
}

class _BrandSplashBody extends StatelessWidget {
  const _BrandSplashBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        DriverAssets.mark,
        width: 88,
        fit: BoxFit.contain,
      ),
    );
  }
}
