import 'package:flutter/material.dart';

/// Shared map styling with the admin panel (Carto Dark Matter + route colors).
class DriverMapConfig {
  static const tilesUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  static const tileSubdomains = ['a', 'b', 'c', 'd'];

  static const routeOrange = Color(0xFFEB4F26);
  static const startGreen = Color(0xFF4ADE80);
  static const endRed = Color(0xFFF87171);
}
