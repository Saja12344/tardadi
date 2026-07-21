import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../onboarding_stagger_reveal.dart';
import '../onboarding_theme.dart';
import '../onboarding_typography.dart';
import '../tardadi_logo.dart';

class HomeScreenPreview extends StatefulWidget {
  const HomeScreenPreview({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

  @override
  State<HomeScreenPreview> createState() => _HomeScreenPreviewState();
}

class _HomeScreenPreviewState extends State<HomeScreenPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: OnboardingPreviewMotion.entrance,
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(HomeScreenPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _s => math.min(widget.width / 320, widget.height / 252);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ColoredBox(
        color: OnboardingTheme.background,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12 * _s, 10 * _s, 12 * _s, 10 * _s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingStaggerReveal(
                animation: _controller,
                interval: OnboardingPreviewMotion.step(0),
                child: Row(
                  children: [
                    TardadiLogoIcon(size: 18 * _s),
                    SizedBox(width: 8 * _s),
                    Expanded(
                      child: Text(
                        'Tardadi',
                        style: OnboardingTypography.display(
                          fontSize: 16 * _s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.menu_rounded,
                      color: OnboardingTheme.white.withValues(alpha: 0.85),
                      size: 18 * _s,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10 * _s),
              OnboardingStaggerReveal(
                animation: _controller,
                interval: OnboardingPreviewMotion.step(1),
                child: _MiniSearchBar(scale: _s),
              ),
              SizedBox(height: 10 * _s),
              OnboardingStaggerReveal(
                animation: _controller,
                interval: OnboardingPreviewMotion.step(2),
                child: _SectionLabel(label: 'Public', scale: _s),
              ),
              SizedBox(height: 8 * _s),
              OnboardingStaggerReveal(
                animation: _controller,
                interval: OnboardingPreviewMotion.step(3),
                child: _MiniRouteCard(
                  scale: _s,
                  name: 'Diriyah',
                  meta: '2 live / 4 · 8 Stations',
                  highlighted: true,
                ),
              ),
              SizedBox(height: 8 * _s),
              OnboardingStaggerReveal(
                animation: _controller,
                interval: OnboardingPreviewMotion.step(4),
                child: _MiniRouteCard(
                  scale: _s,
                  name: 'Roshn',
                  meta: 'Scheduled · 3 Buses · 6 Stations',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSearchBar extends StatelessWidget {
  const _MiniSearchBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 32 * scale,
          padding: EdgeInsets.symmetric(horizontal: 12 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 16 * scale,
                color: OnboardingTheme.white.withValues(alpha: 0.7),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Station name',
                style: OnboardingTypography.body(
                  fontSize: 12 * scale,
                  color: OnboardingTheme.white.withValues(alpha: 0.52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3 * scale,
          height: 14 * scale,
          decoration: BoxDecoration(
            color: OnboardingTheme.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          label,
          style: OnboardingTypography.display(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniRouteCard extends StatelessWidget {
  const _MiniRouteCard({
    required this.scale,
    required this.name,
    required this.meta,
    this.highlighted = false,
  });

  final double scale;
  final String name;
  final String meta;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        10 * scale,
        8 * scale,
        8 * scale,
        8 * scale,
      ),
      decoration: BoxDecoration(
        color: OnboardingTheme.lightCard,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlighted ? 0.08 : 0.06),
            blurRadius: highlighted ? 10 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: OnboardingTypography.display(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: OnboardingTheme.routeTitle,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  meta,
                  style: OnboardingTypography.body(
                    fontSize: 10 * scale,
                    color: OnboardingTheme.routeMeta,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24 * scale,
            height: 24 * scale,
            decoration: const BoxDecoration(
              color: OnboardingTheme.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10 * scale,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
