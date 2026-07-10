import 'package:flutter/material.dart';

/// Keeps the back chevron on the physical left, even in RTL Arabic layout.
class LeftBackButton extends StatelessWidget {
  const LeftBackButton({
    super.key,
    required this.onPressed,
    this.color = Colors.white,
    this.size = 20,
    this.padding = EdgeInsets.zero,
  });

  final VoidCallback onPressed;
  final Color color;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.arrow_back_ios_new, color: color, size: size),
        ),
      ),
    );
  }
}

/// App bar with the back action pinned to the physical left in all locales.
class LeftBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LeftBackAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.backgroundColor,
  });

  final Widget title;
  final VoidCallback onBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: isRtl ? null : LeftBackButton(onPressed: onBack),
      actions: isRtl
          ? [LeftBackButton(onPressed: onBack)]
          : null,
      title: title,
    );
  }
}
