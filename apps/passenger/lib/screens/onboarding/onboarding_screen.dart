import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../account_type_screen.dart';
import '../../widgets/onboarding/location_illustration.dart';
import '../../widgets/onboarding/location_permission_dialog.dart';
import '../../widgets/onboarding/map_illustration.dart';
import '../../widgets/onboarding/onboarding_primary_button.dart';
import '../../widgets/onboarding/onboarding_scale.dart';
import '../../widgets/onboarding/onboarding_theme.dart';
import '../../widgets/onboarding/tardadi_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  var _pageIndex = 0;
  var _showPermissionDialog = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding({required bool requestLocation}) async {
    if (requestLocation) {
      await Geolocator.requestPermission();
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AccountTypeScreen()),
    );
  }

  void _onPrimaryAction() {
    if (_pageIndex == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    setState(() => _showPermissionDialog = true);
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: scale.horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: scale.s(20)),
                  _OnboardingHeader(
                    pageIndex: _pageIndex,
                    scale: scale,
                    tagline: l10n.onboardingTagline,
                  ),
                  SizedBox(height: scale.s(24)),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _pageIndex = index),
                      children: [
                        Center(
                          child: MapIllustration(
                            width: scale.illustrationWidth,
                            height: scale.illustrationHeight,
                          ),
                        ),
                        Center(
                          child: LocationIllustration(
                            width: scale.illustrationWidth,
                            height: scale.illustrationHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: scale.s(20)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _pageIndex == 0
                        ? _OnboardingCopy(
                            key: const ValueKey('page-1'),
                            scale: scale,
                            title: l10n.onboardingTitle1,
                            subtitle: l10n.onboardingSubtitle1,
                          )
                        : _OnboardingCopy(
                            key: const ValueKey('page-2'),
                            scale: scale,
                            title: l10n.onboardingTitle2,
                            subtitle: l10n.onboardingSubtitle2,
                          ),
                  ),
                  SizedBox(height: scale.s(20)),
                  OnboardingPageIndicator(
                    count: 2,
                    currentIndex: _pageIndex,
                    scale: scale,
                  ),
                  SizedBox(height: scale.s(24)),
                  OnboardingPrimaryButton(
                    scale: scale,
                    label:
                        _pageIndex == 0 ? l10n.next : l10n.allowLocation,
                    onPressed: _onPrimaryAction,
                  ),
                  SizedBox(height: scale.s(20)),
                ],
              ),
            ),
          ),
          if (_showPermissionDialog)
            LocationPermissionDialog(
              onAllowOnce: () => _finishOnboarding(requestLocation: true),
              onAllowWhileUsing: () => _finishOnboarding(requestLocation: true),
              onDeny: () => _finishOnboarding(requestLocation: false),
            ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.pageIndex,
    required this.scale,
    required this.tagline,
  });

  final int pageIndex;
  final OnboardingScale scale;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    if (pageIndex == 0) {
      return Column(
        children: [
          TardadiLogoIcon(size: scale.logoIconSize),
          SizedBox(height: scale.s(12)),
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OnboardingTheme.muted,
              fontSize: scale.onboardingTaglineSize,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return TardadiLogo(
      iconSize: scale.compactLogoIconSize,
      arabicSize: scale.compactArabicSize,
      englishSize: scale.compactEnglishSize,
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: OnboardingTheme.white,
            fontSize: scale.onboardingTitleSize,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        SizedBox(height: scale.s(10)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: OnboardingTheme.muted,
            fontSize: scale.onboardingSubtitleSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
