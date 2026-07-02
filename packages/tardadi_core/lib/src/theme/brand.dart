import 'package:flutter/material.dart';

class TardadiBrand {
  static const Color orange = Color(0xFFE95026);
  static const Color navy = Color(0xFF13154B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color card = Color(0xFF1A1D5C);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      colorScheme: const ColorScheme.dark(
        primary: orange,
        surface: card,
        onPrimary: white,
        onSurface: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: grey),
      ),
    );
  }
}
