import 'dart:ui';

import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

enum FrostedGlassVariant { card, dark }

/// Lightweight glassmorphism: backdrop blur + thin translucent gradient overlay.
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.variant = FrostedGlassVariant.card,
    this.borderRadius = OnboardingTheme.figmaCardRadius,
    this.padding,
    this.margin,
    this.border,
    this.width,
    this.height,
    this.blurSigma,
    this.showGlow = false,
    this.showBorder = true,
    this.fillOpacity = 0.10,
    this.tintColor,
  });

  final Widget child;
  final FrostedGlassVariant variant;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final double? width;
  final double? height;
  final double? blurSigma;
  final bool showGlow;
  final bool showBorder;
  final double fillOpacity;
  final Color? tintColor;

  double get _effectiveBlur =>
      blurSigma ?? (variant == FrostedGlassVariant.dark ? 10 : 8);

  @override
  Widget build(BuildContext context) {
    final decoration = switch (variant) {
      FrostedGlassVariant.dark => _darkGlassDecoration(),
      FrostedGlassVariant.card => _lightGlassDecoration(),
    };

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.08),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _effectiveBlur,
            sigmaY: _effectiveBlur,
          ),
          child: Container(
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _darkGlassDecoration() {
    final tint = tintColor ?? Colors.white;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tint.withValues(alpha: 0.14),
          tint.withValues(alpha: 0.05),
        ],
      ),
      border: border ??
          (showBorder
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1,
                )
              : null),
    );
  }

  BoxDecoration _lightGlassDecoration() {
    final tint = Color(0xFFD9D9D9).withValues(
      alpha: fillOpacity.clamp(0.0, 1.0),
    );

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: fillOpacity + 0.04),
          tint,
        ],
      ),
      border: border ??
          (showBorder
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1,
                )
              : null),
    );
  }
}
