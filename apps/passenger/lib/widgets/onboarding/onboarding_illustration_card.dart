import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class OnboardingIllustrationCard extends StatelessWidget {
  const OnboardingIllustrationCard({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: OnboardingTheme.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: OnboardingTheme.white.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: OnboardingTheme.orange.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
