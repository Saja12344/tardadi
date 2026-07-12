import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_permissions.dart';
import '../account_type_screen.dart';
import '../../widgets/onboarding/location_illustration.dart';
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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  var _pageIndex = 0;
  var _finishing = false;

  late final AnimationController _enterController;
  late final AnimationController _contentController;
  late final Animation<double> _brandFade;
  late final Animation<Offset> _brandSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _brandFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _enterController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _enterController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    await AppPermissions.requestOnboardingLocation();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const AccountTypeScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  Future<void> _onPrimaryAction() async {
    if (_pageIndex == 0) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finishOnboarding();
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    _contentController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;
    final stepLabel =
        _pageIndex == 0 ? l10n.onboardingStepPlan : l10n.onboardingStepLocate;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [
              Color(0xFF1C1F63),
              OnboardingTheme.background,
            ],
            stops: [0, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(
                size: scale.s(220),
                color: OnboardingTheme.orange.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: scale.s(120),
              left: -70,
              child: _GlowOrb(
                size: scale.s(180),
                color: const Color(0xFF2A2F7A).withValues(alpha: 0.55),
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: scale.horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: scale.s(18)),
                    FadeTransition(
                      opacity: _brandFade,
                      child: SlideTransition(
                        position: _brandSlide,
                        child: _BrandHeader(
                          scale: scale,
                          appName: l10n.appName,
                          tagline: l10n.onboardingTagline,
                          stepLabel: stepLabel,
                        ),
                      ),
                    ),
                    SizedBox(height: scale.s(18)),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        children: [
                          _IllustrationStage(
                            scale: scale,
                            child: MapIllustration(
                              width: scale.illustrationWidth,
                              height: scale.illustrationHeight,
                            ),
                          ),
                          _IllustrationStage(
                            scale: scale,
                            child: LocationIllustration(
                              width: scale.illustrationWidth,
                              height: scale.illustrationHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: scale.s(12)),
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: _OnboardingCopy(
                          key: ValueKey('copy-$_pageIndex'),
                          scale: scale,
                          title: _pageIndex == 0
                              ? l10n.onboardingTitle1
                              : l10n.onboardingTitle2,
                          subtitle: _pageIndex == 0
                              ? l10n.onboardingSubtitle1
                              : l10n.onboardingSubtitle2,
                        ),
                      ),
                    ),
                    SizedBox(height: scale.s(18)),
                    OnboardingPageIndicator(
                      count: 2,
                      currentIndex: _pageIndex,
                      scale: scale,
                    ),
                    SizedBox(height: scale.s(20)),
                    OnboardingPrimaryButton(
                      scale: scale,
                      label: _pageIndex == 0 ? l10n.next : l10n.allowLocation,
                      onPressed: _finishing ? null : _onPrimaryAction,
                    ),
                    SizedBox(height: scale.s(18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.scale,
    required this.appName,
    required this.tagline,
    required this.stepLabel,
  });

  final OnboardingScale scale;
  final String appName;
  final String tagline;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TardadiLogoIcon(size: scale.s(34)),
            SizedBox(width: scale.s(10)),
            Text(
              appName,
              style: GoogleFonts.ubuntu(
                color: OnboardingTheme.cream,
                fontSize: scale.s(34),
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: scale.s(10)),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: OnboardingTheme.muted,
            fontSize: scale.onboardingTaglineSize,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: scale.s(14)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Container(
            key: ValueKey(stepLabel),
            padding: EdgeInsets.symmetric(
              horizontal: scale.s(12),
              vertical: scale.s(6),
            ),
            decoration: BoxDecoration(
              color: OnboardingTheme.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: OnboardingTheme.orange.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              stepLabel,
              style: GoogleFonts.ubuntu(
                color: OnboardingTheme.orange,
                fontSize: scale.s(11),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IllustrationStage extends StatelessWidget {
  const _IllustrationStage({
    required this.scale,
    required this.child,
  });

  final OnboardingScale scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeOutCubic,
        builder: (context, value, animatedChild) {
          return Opacity(
            opacity: ((value - 0.94) / 0.06).clamp(0.0, 1.0),
            child: Transform.scale(scale: value, child: animatedChild),
          );
        },
        child: Container(
          width: scale.illustrationWidth,
          height: scale.illustrationHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: OnboardingTheme.orange.withValues(alpha: 0.12),
                blurRadius: 36,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: OnboardingTheme.cream.withValues(alpha: 0.18),
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: child,
            ),
          ),
        ),
      ),
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
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: OnboardingTheme.cream,
            fontSize: scale.s(26),
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: scale.s(10)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: OnboardingTheme.muted,
            fontSize: scale.onboardingSubtitleSize,
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
