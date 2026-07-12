import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
import '../../widgets/onboarding/onboarding_scale.dart';
import '../../widgets/onboarding/onboarding_theme.dart';
import '../../widgets/onboarding/tardadi_mark.dart';

/// Single branded splash after the plain navy native launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _drive;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.2, curve: Curves.easeOut),
    );

    // Bus rolls in once, settles, then we open onboarding.
    _drive = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.25, 0.02),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 72,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.03, 0),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
    ]).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward().then((_) {
        if (!mounted) return;
        _goToOnboarding();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final logoSize = scale.s(140);

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: Center(
        child: SlideTransition(
          position: _drive,
          textDirection: TextDirection.ltr,
          child: FadeTransition(
            opacity: _fadeIn,
            child: TardadiMark(size: logoSize),
          ),
        ),
      ),
    );
  }
}
