import 'package:flutter/material.dart';

import '../../widgets/animated_brand_splash.dart';
import '../../widgets/onboarding/onboarding_theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _navigated = false;

  void _finishSplash() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: OnboardingTheme.background,
        body: AnimatedBrandSplash(onFinished: _finishSplash),
      ),
    );
  }
}
