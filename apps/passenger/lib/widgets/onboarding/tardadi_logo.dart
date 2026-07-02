import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class TardadiLogoIcon extends StatelessWidget {
  const TardadiLogoIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_icon.png',
      width: size,
      height: size,
    );
  }
}

class TardadiLogo extends StatelessWidget {
  const TardadiLogo({
    super.key,
    this.iconSize = 24,
    this.arabicSize = 18,
    this.englishSize = 22,
    this.compact = true,
  });

  final double iconSize;
  final double arabicSize;
  final double englishSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!compact) {
      return Image.asset(
        'assets/images/logo_full.png',
        height: iconSize * 2,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ترددي',
          style: TextStyle(
            color: OnboardingTheme.orange,
            fontSize: arabicSize,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Tardadi',
              style: TextStyle(
                color: OnboardingTheme.orange,
                fontSize: englishSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            TardadiLogoIcon(size: iconSize),
          ],
        ),
      ],
    );
  }
}
