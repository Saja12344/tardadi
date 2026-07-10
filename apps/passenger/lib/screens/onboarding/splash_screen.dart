import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
import '../../widgets/onboarding/onboarding_scale.dart';
import '../../widgets/onboarding/onboarding_theme.dart';
import '../../widgets/tardadi_brand_video.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _navigated = false;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    Future<void>.delayed(const Duration(seconds: 5), _finishSplash);
  }

  void _finishSplash() {
    if (_navigated || !mounted) return;
    final elapsed = DateTime.now().difference(_startedAt!);
    const minDuration = Duration(milliseconds: 2400);
    final remaining = minDuration - elapsed;

    Future<void>.delayed(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (!mounted || _navigated) return;
        _navigated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final logoSize = scale.s(160);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: OnboardingTheme.background,
        body: Center(
          child: TardadiSplashVideo(
            size: logoSize,
            onFinished: _finishSplash,
          ),
        ),
      ),
    );
  }
}
