import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform_ui.dart';

class DriverColors {
  static const navy = Color(0xFF12144A);
  static const navyDeep = Color(0xFF12144A);
  static const navyPanel = Color(0xFF24277A);
  static const sideMenu = Color(0xFF24277A);
  static const orange = Color(0xFFEA4F26);
  static const muted = Color(0xFF9EA0AA);
  static const softWhite = Color(0xFFF8F8F8);
  static const card = Color(0xFF2B2E59);
  static const green = Color(0xFF20B756);
}

class DriverAssets {
  static const wordmark = 'assets/images/tardadi_wordmark.png';
  static const mark = 'assets/images/tardadi_mark.png';
  static const vehicleBus = 'assets/images/vehicles/bus.png';
  static const vehicleGolf = 'assets/images/vehicles/golf.png';
  static const vehicleVan = 'assets/images/vehicles/van.png';
  static const vehicleCar = 'assets/images/vehicles/car.png';
}

/// Unified status bar + home-indicator colors per screen type.
class DriverChrome extends StatelessWidget {
  const DriverChrome({
    super.key,
    required this.child,
    this.barColor = DriverColors.navy,
    this.bodyColor = DriverColors.navy,
  });

  final Widget child;
  final Color barColor;
  final Color bodyColor;

  static const _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: DriverColors.navy,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        backgroundColor: bodyColor,
        resizeToAvoidBottomInset: false,
        body: child,
      ),
    );
  }
}

/// Full-screen panel that slides in from the left (hides map completely).
class DriverLeftSlidePanel extends StatelessWidget {
  const DriverLeftSlidePanel({
    super.key,
    required this.visible,
    required this.onClose,
    required this.child,
  });

  final bool visible;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final hiddenOffset = Offset(isRtl ? 1 : -1, 0);

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : hiddenOffset,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DriverColors.navyDeep,
            boxShadow: visible
                ? [
                    BoxShadow(
                      color: const Color(0x66000000),
                      blurRadius: 24,
                      offset: Offset(isRtl ? -8 : 8, 0),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              SizedBox(height: top),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
              SizedBox(height: bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// @deprecated Use [DriverLeftSlidePanel].
typedef DriverRightSlidePanel = DriverLeftSlidePanel;

/// Right-side settings panel with dimmed map peek on the left (settings.png).
class DriverSidePanel extends StatelessWidget {
  const DriverSidePanel({
    super.key,
    required this.onClose,
    required this.child,
  });

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = MediaQuery.sizeOf(context).width;
    final peekWidth = width * 0.2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: DriverChrome._overlayStyle,
      child: Scaffold(
        backgroundColor: DriverColors.navy,
        body: Column(
        children: [
          SizedBox(height: top, child: const ColoredBox(color: DriverColors.navyPanel)),
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: peekWidth,
                    child: ColoredBox(
                      color: DriverColors.navy.withValues(alpha: 0.72),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 42),
                          child: Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: DriverColors.navyPanel,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: bottom,
            child: const ColoredBox(color: DriverColors.navyPanel),
          ),
        ],
      ),
      ),
    );
  }
}

Route<T> driverRoute<T>({
  required WidgetBuilder builder,
  Offset? beginOffset,
}) {
  Widget page(BuildContext context) =>
      ColoredBox(color: DriverColors.navy, child: builder(context));

  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoPageRoute<T>(builder: page);
  }

  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      final resolvedBegin = beginOffset ??
          Offset(isRtl ? -0.06 : 0.06, 0);
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: resolvedBegin,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class DriverChevronForward extends StatelessWidget {
  const DriverChevronForward({
    super.key,
    this.color,
    this.size = 20,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: color,
      size: size,
    );
  }
}

class DriverButton extends StatelessWidget {
  const DriverButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = DriverColors.orange,
    this.textColor = Colors.white,
    this.height = 54,
    this.fontSize = 26,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: DriverColors.card,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: onPressed == null
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
          ),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

class DriverSnack {
  static void show(BuildContext context, String message) {
    showPlatformMessage(context, message);
  }
}
