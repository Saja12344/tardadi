import 'package:flutter/material.dart';

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
}

Route<T> driverRoute<T>({
  required WidgetBuilder builder,
  Offset beginOffset = const Offset(0.06, 0),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ColoredBox(color: DriverColors.navy, child: builder(context));
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DriverColors.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
