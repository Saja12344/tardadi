import 'package:flutter/material.dart';

import 'onboarding_scale.dart';
import 'onboarding_theme.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.scale,
  });

  final String label;
  final VoidCallback onPressed;
  final OnboardingScale scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OnboardingTheme.orange,
          foregroundColor: OnboardingTheme.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: scale.buttonVerticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: scale.buttonFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.scale,
  });

  final int count;
  final int currentIndex;
  final OnboardingScale scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == currentIndex;
        return Container(
          width: active ? scale.s(10) : scale.s(8),
          height: scale.s(8),
          margin: EdgeInsets.symmetric(horizontal: scale.s(4)),
          decoration: BoxDecoration(
            color: active
                ? OnboardingTheme.orange
                : OnboardingTheme.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
