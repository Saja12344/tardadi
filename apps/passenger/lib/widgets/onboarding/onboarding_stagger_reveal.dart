import 'package:flutter/material.dart';

/// Fades and slides a child in during a staggered [interval] of [animation].
class OnboardingStaggerReveal extends StatelessWidget {
  const OnboardingStaggerReveal({
    super.key,
    required this.animation,
    required this.interval,
    required this.child,
    this.slideOffset = const Offset(0, 0.1),
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: interval,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: slideOffset,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Moderate one-by-one entrance timing for onboarding previews.
abstract final class OnboardingPreviewMotion {
  static const Duration entrance = Duration(milliseconds: 1500);
  static const Curve curve = Curves.easeOutCubic;

  static Interval step(int index, {int total = 5, double overlap = 0.12}) {
    final slot = 1 / total;
    final start = (index * slot - overlap).clamp(0.0, 1.0);
    final end = ((index + 1) * slot + overlap).clamp(0.0, 1.0);
    return Interval(start, end, curve: curve);
  }
}
