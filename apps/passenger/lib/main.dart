import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import 'screens/map_screen.dart';

void main() {
  runApp(const TardadiPassengerApp());
}

class TardadiPassengerApp extends StatelessWidget {
  const TardadiPassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ترددي — راكب',
      theme: TardadiBrand.darkTheme(),
      home: const MapScreen(),
    );
  }
}
