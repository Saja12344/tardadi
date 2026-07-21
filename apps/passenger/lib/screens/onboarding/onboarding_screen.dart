import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_permissions.dart';
import '../account_type_screen.dart';
import '../../widgets/onboarding/onboarding_feature_preview_card.dart';
import '../../widgets/onboarding/onboarding_primary_button.dart';
import '../../widgets/onboarding/onboarding_scale.dart';
import '../../widgets/onboarding/onboarding_theme.dart';
import '../../widgets/onboarding/onboarding_typography.dart';
import '../../widgets/onboarding/previews/home_screen_preview.dart';
import '../../widgets/onboarding/previews/tracking_screen_preview.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const _pageCount = 2;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  var _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding({required bool requestLocation}) async {
    await AppPermissions.requestOnboardingPermissions(
      requestLocation: requestLocation,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AccountTypeScreen()),
    );
  }

  void _onPrimaryAction() {
    if (_pageIndex < OnboardingScreen._pageCount - 1) {
      _pageController.nextPage(
        duration: OnboardingTheme.motionMedium,
        curve: OnboardingTheme.motionCurve,
      );
      return;
    }
    _finishOnboarding(requestLocation: true);
  }

  Widget _previewForIndex(int index, OnboardingScale scale) {
    final width = scale.illustrationWidth;
    final height = scale.featureCardHeight;
    final isActive = _pageIndex == index;

    return switch (index) {
      0 => HomeScreenPreview(
          width: width,
          height: height,
          isActive: isActive,
        ),
      _ => TrackingScreenPreview(
          width: width,
          height: height,
          isActive: isActive,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;

    final titles = [l10n.onboardingTitle1, l10n.onboardingTitle2];
    final subtitles = [l10n.onboardingSubtitle1, l10n.onboardingSubtitle2];

    final buttonLabel = _pageIndex < OnboardingScreen._pageCount - 1
        ? l10n.next
        : l10n.allowLocation;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: scale.horizontalPadding),
          child: Column(
            children: [
                  SizedBox(height: scale.s(16)),
                  _OnboardingHeader(
                    scale: scale,
                    tagline: l10n.onboardingTagline,
                  ),
                  SizedBox(height: scale.s(20)),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: scale.s(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            clipBehavior: Clip.hardEdge,
                            child: SizedBox(
                              width: scale.illustrationWidth,
                              height: scale.featureCardHeight,
                              child: PageView.builder(
                                controller: _pageController,
                                clipBehavior: Clip.hardEdge,
                                itemCount: OnboardingScreen._pageCount,
                                onPageChanged: (index) =>
                                    setState(() => _pageIndex = index),
                                itemBuilder: (context, index) {
                                  return OnboardingFeaturePreviewCard(
                                    width: scale.illustrationWidth,
                                    height: scale.featureCardHeight,
                                    child: _previewForIndex(index, scale),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: scale.s(32)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: scale.copyHorizontalInset,
                          ),
                          child: _OnboardingCopy(
                            key: ValueKey('copy-$_pageIndex'),
                            scale: scale,
                            title: titles[_pageIndex],
                            subtitle: subtitles[_pageIndex],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scale.s(16)),
                  OnboardingPageIndicator(
                    count: OnboardingScreen._pageCount,
                    currentIndex: _pageIndex,
                    scale: scale,
                    pageController: _pageController,
                  ),
                  SizedBox(height: scale.s(24)),
                  OnboardingPrimaryButton(
                    scale: scale,
                    label: buttonLabel,
                    onPressed: _onPrimaryAction,
                  ),
                  SizedBox(height: scale.s(16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.scale,
    required this.tagline,
  });

  final OnboardingScale scale;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_full.png',
          height: scale.s(44),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        SizedBox(height: scale.s(8)),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: OnboardingTypography.body(
            fontSize: scale.onboardingTaglineSize,
            fontWeight: FontWeight.w500,
            color: OnboardingTheme.muted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _OnboardingCopy extends StatefulWidget {
  const _OnboardingCopy({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
  });

  final OnboardingScale scale;
  final String title;
  final String subtitle;

  @override
  State<_OnboardingCopy> createState() => _OnboardingCopyState();
}

class _OnboardingCopyState extends State<_OnboardingCopy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: OnboardingTheme.motionFast,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: OnboardingTheme.motionCurve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_OnboardingCopy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return FadeTransition(
      opacity: _fade,
      child: Column(
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: OnboardingTypography.display(
              fontSize: scale.onboardingTitleSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: scale.s(8)),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: OnboardingTypography.body(
              fontSize: scale.onboardingSubtitleSize,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
