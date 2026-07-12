import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

/// Brand mark from the official PNG logo asset.
class TardadiMark extends StatelessWidget {
  const TardadiMark({
    super.key,
    this.size = 112,
    this.color = OnboardingTheme.orange,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/logo_icon.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      fit: BoxFit.contain,
    );

    if (color == OnboardingTheme.orange) {
      return SizedBox(width: size, height: size, child: image);
    }

    return SizedBox(
      width: size,
      height: size,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: image,
      ),
    );
  }
}
