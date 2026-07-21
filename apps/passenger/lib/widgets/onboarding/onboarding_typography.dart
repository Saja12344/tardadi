import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

abstract final class OnboardingTypography {
  static bool get _isIos => Platform.isIOS;

  static List<String> get _displayFallback => _isIos
      ? const ['SF Pro Display', 'Helvetica Neue', 'Arial']
      : const ['Roboto', 'sans-serif'];

  static List<String> get _textFallback => _isIos
      ? const ['SF Pro Text', 'Helvetica Neue', 'Arial']
      : const ['Roboto', 'sans-serif'];

  static String? get _displayFamily =>
      _isIos ? '.SF Pro Display' : 'Roboto';

  static String? get _textFamily => _isIos ? '.SF Pro Text' : 'Roboto';

  static TextStyle display({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color color = OnboardingTheme.white,
    double height = 1.2,
    double letterSpacing = -0.3,
  }) {
    return TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = OnboardingTheme.muted,
    double height = 1.45,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: _textFamily,
      fontFamilyFallback: _textFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color color = OnboardingTheme.white,
  }) {
    return TextStyle(
      fontFamily: _textFamily,
      fontFamilyFallback: _textFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
