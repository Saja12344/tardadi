import 'package:flutter/material.dart';

import 'onboarding_scale.dart';
import 'onboarding_theme.dart';

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({
    super.key,
    required this.scale,
    required this.onBack,
  });

  final OnboardingScale scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: OnboardingTheme.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(scale.s(32)),
          bottomRight: Radius.circular(scale.s(32)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: scale.size.height * 0.34,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              scale.s(12),
              scale.s(8),
              scale.s(12),
              scale.s(28),
            ),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_full.png',
                      height: scale.s(92),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
