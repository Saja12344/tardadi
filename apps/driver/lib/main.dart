import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import 'screens/login_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const TardadiDriverApp());
}

class TardadiDriverApp extends StatelessWidget {
  const TardadiDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ترددي — سائق',
      theme: TardadiBrand.darkTheme(),
      home: const LoginScreen(),
      routes: {
        '/map': (_) => const MapScreen(),
      },
    );
  }
}
