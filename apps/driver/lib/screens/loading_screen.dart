import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../services/session_store.dart';
import '../ui/driver_design.dart';
import 'map_screen.dart';

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
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(driverRoute(builder: (_) => const MapScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverColors.navy,
      body: Center(
        child: Image.asset(DriverAssets.mark, width: 78, fit: BoxFit.contain),
      ),
    );
  }
}
