import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
import '../../widgets/onboarding/onboarding_scale.dart';
import '../../widgets/onboarding/onboarding_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _tilt;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.6, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.06, -0.02),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.06, -0.02),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 22,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 68,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 32,
      ),
    ]).animate(_controller);

    _tilt = Tween<double>(begin: -0.12, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.15, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward().then((_) {
        Future<void>.delayed(const Duration(milliseconds: 500), _goToOnboarding);
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
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final logoSize = scale.s(132);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: OnboardingTheme.background,
            body: Center(
              child: SlideTransition(
                position: _slide,
                textDirection: TextDirection.ltr,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Transform.rotate(
                    angle: _tilt.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: Image.asset(
          'assets/images/logo_icon.png',
          width: logoSize,
          height: logoSize,
        ),
      ),
    );
  }
}
