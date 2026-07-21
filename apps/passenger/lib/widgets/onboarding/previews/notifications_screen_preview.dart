import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_typography.dart';

class NotificationsScreenPreview extends StatefulWidget {
  const NotificationsScreenPreview({
    super.key,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  final double width;
  final double height;
  final bool isActive;

  @override
  State<NotificationsScreenPreview> createState() =>
      _NotificationsScreenPreviewState();
}

class _NotificationsScreenPreviewState extends State<NotificationsScreenPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(NotificationsScreenPreview oldWidget) {
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

  double get _s => widget.width / 320;

  @override
  Widget build(BuildContext context) {
    final notificationSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    final contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ColoredBox(
        color: OnboardingTheme.background,
        child: Padding(
          padding: EdgeInsets.all(10 * _s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.35),
                  end: Offset.zero,
                ).animate(notificationSlide),
                child: FadeTransition(
                  opacity: notificationSlide,
                  child: _NotificationBanner(scale: _s),
                ),
              ),
              SizedBox(height: 14 * _s),
              FadeTransition(
                opacity: contentFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SavedRouteRow(scale: _s),
                    SizedBox(height: 10 * _s),
                    _FavoriteStopRow(scale: _s),
                    SizedBox(height: 10 * _s),
                    _LiveRouteWidget(scale: _s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              color: OnboardingTheme.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: OnboardingTheme.orange,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tardadi',
                  style: OnboardingTypography.label(
                    fontSize: 10 * scale,
                    color: const Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Bus arriving in 2 minutes',
                  style: OnboardingTypography.label(
                    fontSize: 12 * scale,
                    color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedRouteRow extends StatelessWidget {
  const _SavedRouteRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      scale: scale,
      child: Row(
        children: [
          Icon(Icons.bookmark_rounded, color: OnboardingTheme.orange, size: 18 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved route',
                  style: OnboardingTypography.label(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Diriyah · Gate 2',
                  style: OnboardingTypography.body(
                    fontSize: 10 * scale,
                    color: OnboardingTheme.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: OnboardingTheme.muted,
            size: 18 * scale,
          ),
        ],
      ),
    );
  }
}

class _FavoriteStopRow extends StatelessWidget {
  const _FavoriteStopRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      scale: scale,
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: OnboardingTheme.orange, size: 18 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorite station',
                  style: OnboardingTypography.label(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Main Gate · Route 24',
                  style: OnboardingTypography.body(
                    fontSize: 10 * scale,
                    color: OnboardingTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveRouteWidget extends StatelessWidget {
  const _LiveRouteWidget({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _SurfaceTile(
      scale: scale,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route 24',
                  style: OnboardingTypography.label(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  '2 buses live now',
                  style: OnboardingTypography.body(
                    fontSize: 10 * scale,
                    color: OnboardingTheme.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: OnboardingTheme.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5 * scale,
                  height: 5 * scale,
                  decoration: const BoxDecoration(
                    color: OnboardingTheme.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Text(
                  'Live',
                  style: OnboardingTypography.label(
                    fontSize: 10 * scale,
                    color: OnboardingTheme.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceTile extends StatelessWidget {
  const _SurfaceTile({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: OnboardingTheme.card,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: child,
    );
  }
}
