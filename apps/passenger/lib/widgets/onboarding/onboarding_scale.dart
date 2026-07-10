import 'dart:math' as math;

import 'package:flutter/material.dart';

const _designWidth = 390.0;
const _designHeight = 844.0;

/// Scales onboarding layout values from the Figma reference frame (390×844).
class OnboardingScale {
  OnboardingScale(BuildContext context)
      : size = MediaQuery.sizeOf(context),
        padding = MediaQuery.paddingOf(context) {
    final widthScale = size.width / _designWidth;
    final heightScale = size.height / _designHeight;
    factor = math.min(widthScale, heightScale).clamp(0.72, 1.22);
    horizontalPadding = (size.width * 0.07).clamp(20.0, 32.0);
  }

  final Size size;
  final EdgeInsets padding;
  late final double factor;
  late final double horizontalPadding;

  double s(double designPixels) => designPixels * factor;

  double get logoIconSize => s(28);

  double get accountLogoSize => s(64);

  double get splashLogoSize => s(44);

  double get illustrationWidth =>
      (size.width - horizontalPadding * 2).clamp(280.0, 360.0);

  double get illustrationHeight =>
      math.min(illustrationWidth * 0.78, size.height * 0.38);

  double get onboardingTitleSize => s(22);

  double get onboardingSubtitleSize => s(14);

  double get onboardingTaglineSize => s(11);

  double get buttonVerticalPadding => s(16);

  double get buttonFontSize => s(17);

  double get sectionSpacing => s(28);

  double get blockSpacing => s(32);

  double get compactArabicSize => s(18);

  double get compactEnglishSize => s(24);

  double get compactLogoIconSize => s(22);

  double get accountTitleSize => s(24);

  double get accountSubtitleSize => s(14);

  double get verifyHeaderLogoHeight => s(72);

  double get verifyTitleSize => s(24);

  double get verifySubtitleSize => s(15);

  double get otpBoxSize => s(44);

  double get otpBoxHeight => s(52);

  double get keypadKeyHeight => s(52);
}
