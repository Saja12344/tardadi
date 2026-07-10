import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding/onboarding_scale.dart';
import 'onboarding/onboarding_theme.dart';
import 'tardadi_brand_video.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.name,
    required this.frequencyLabel,
    required this.busCountLabel,
    required this.stationsCountLabel,
    this.onTap,
  });

  final String name;
  final String frequencyLabel;
  final String busCountLabel;
  final String stationsCountLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final arrow = Container(
      width: scale.s(34),
      height: scale.s(34),
      decoration: BoxDecoration(
        color: OnboardingTheme.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: OnboardingTheme.orange.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isRtl
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
        color: Colors.white,
        size: scale.s(16),
      ),
    );

    final title = Expanded(
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.ubuntu(
          fontSize: scale.s(22),
          fontWeight: FontWeight.w700,
          color: OnboardingTheme.routeTitle,
          height: 1.15,
          letterSpacing: -0.2,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: scale.s(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OnboardingTheme.figmaCardRadius),
          splashColor: OnboardingTheme.orange.withValues(alpha: 0.08),
          highlightColor: OnboardingTheme.orange.withValues(alpha: 0.04),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OnboardingTheme.figmaCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(OnboardingTheme.figmaCardRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(OnboardingTheme.figmaCardRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      scale.s(16),
                      scale.s(14),
                      scale.s(14),
                      scale.s(12),
                    ),
                    decoration: BoxDecoration(
                      color: OnboardingTheme.lightCard,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: isRtl
                                ? [
                                    arrow,
                                    SizedBox(width: scale.s(10)),
                                    title,
                                  ]
                                : [
                                    title,
                                    SizedBox(width: scale.s(10)),
                                    arrow,
                                  ],
                          ),
                        ),
                        SizedBox(height: scale.s(14)),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: scale.s(10),
                            vertical: scale.s(8),
                          ),
                          decoration: BoxDecoration(
                            color: OnboardingTheme.routeTitle
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _MetaItem(
                                  scale: scale,
                                  icon: Icons.schedule_rounded,
                                  label: frequencyLabel,
                                ),
                              ),
                              _MetaDivider(scale: scale),
                              Expanded(
                                child: _MetaItem(
                                  scale: scale,
                                  icon: Icons.directions_bus_rounded,
                                  label: busCountLabel,
                                ),
                              ),
                              _MetaDivider(scale: scale),
                              Expanded(
                                child: _MetaItem(
                                  scale: scale,
                                  icon: Icons.location_on_rounded,
                                  label: stationsCountLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider({required this.scale});

  final OnboardingScale scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: scale.s(22),
      margin: EdgeInsets.symmetric(horizontal: scale.s(4)),
      color: OnboardingTheme.routeMeta.withValues(alpha: 0.18),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.scale,
    required this.icon,
    required this.label,
  });

  final OnboardingScale scale;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: scale.s(14), color: OnboardingTheme.routeMeta),
        SizedBox(width: scale.s(4)),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ubuntu(
              color: OnboardingTheme.routeMeta,
              fontSize: scale.s(12),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class AccountTypeOption extends StatelessWidget {
  const AccountTypeOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.titleSize = 22,
    this.subtitleSize = 13,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: scale.s(16)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: OnboardingTheme.orange.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            constraints: BoxConstraints(minHeight: scale.s(118)),
            padding: EdgeInsets.symmetric(
              horizontal: scale.s(16),
              vertical: scale.s(14),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: selected
                    ? OnboardingTheme.orange
                    : Colors.white.withValues(alpha: 0.14),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: scale.s(58),
                  height: scale.s(58),
                  decoration: BoxDecoration(
                    color: OnboardingTheme.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: OnboardingTheme.orange.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: OnboardingTheme.orange,
                    size: scale.s(30),
                  ),
                ),
                SizedBox(width: scale.s(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.ubuntu(
                          color: OnboardingTheme.orange,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: scale.s(6)),
                      Text(
                        subtitle,
                        style: GoogleFonts.ubuntu(
                          color: OnboardingTheme.white.withValues(alpha: 0.58),
                          fontSize: subtitleSize,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: scale.s(26),
                  height: scale.s(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? OnboardingTheme.orange
                        : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: selected
                          ? OnboardingTheme.orange
                          : Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: scale.s(16),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogoWatermark extends StatelessWidget {
  const LogoWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.max(constraints.maxWidth, constraints.maxHeight) * 1.2;

        return IgnorePointer(
          child: SizedBox.expand(
            child: Center(
              child: TardadiBrandVideo(
                size: side,
                opacity: 0.06,
                loop: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

class WhiteLogoIcon extends StatelessWidget {
  const WhiteLogoIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      child: Image.asset(
        'assets/images/logo_icon.png',
        width: size,
        height: size,
      ),
    );
  }
}
