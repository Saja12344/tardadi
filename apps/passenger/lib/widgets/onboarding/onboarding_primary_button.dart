import 'package:flutter/material.dart';

import 'onboarding_scale.dart';
import 'onboarding_theme.dart';
import 'onboarding_typography.dart';

class OnboardingPrimaryButton extends StatefulWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.scale,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback onPressed;
  final OnboardingScale scale;
  final bool showArrow;

  @override
  State<OnboardingPrimaryButton> createState() => _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: OnboardingTheme.motionFast,
      curve: OnboardingTheme.motionCurve,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.92 : 1,
        duration: OnboardingTheme.motionFast,
        child: SizedBox(
          width: double.infinity,
          height: scale.buttonHeight,
          child: Material(
            color: OnboardingTheme.orange,
            borderRadius: BorderRadius.circular(scale.buttonRadius),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: _setPressed,
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: OnboardingTypography.label(
                        fontSize: scale.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        color: OnboardingTheme.white,
                      ),
                    ),
                    if (widget.showArrow) ...[
                      const SizedBox(width: 6),
                      AnimatedSlide(
                        offset: _pressed
                            ? const Offset(0.08, 0)
                            : Offset.zero,
                        duration: OnboardingTheme.motionFast,
                        curve: OnboardingTheme.motionCurve,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: scale.s(20),
                          color: OnboardingTheme.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
    this.pageController,
  });

  final int count;
  final int currentIndex;
  final OnboardingScale scale;
  final PageController? pageController;

  @override
  Widget build(BuildContext context) {
    final dotHeight = scale.s(8);
    final dotSpacing = scale.s(8);

    Widget buildIndicator(double page) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final distance = (page - index).abs();
          final active = (1 - distance.clamp(0.0, 1.0));
          final width = scale.s(8) + active * scale.s(16);

          return AnimatedContainer(
            duration: OnboardingTheme.motionMedium,
            curve: OnboardingTheme.motionCurve,
            margin: EdgeInsets.symmetric(horizontal: dotSpacing / 2),
            width: width,
            height: dotHeight,
            decoration: BoxDecoration(
              color: active > 0.5
                  ? OnboardingTheme.orange
                  : OnboardingTheme.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(dotHeight / 2),
            ),
          );
        }),
      );
    }

    if (pageController != null) {
      return AnimatedBuilder(
        animation: pageController!,
        builder: (context, _) {
          final page = pageController!.hasClients
              ? (pageController!.page ?? currentIndex.toDouble())
              : currentIndex.toDouble();
          return buildIndicator(page);
        },
      );
    }

    return buildIndicator(currentIndex.toDouble());
  }
}
