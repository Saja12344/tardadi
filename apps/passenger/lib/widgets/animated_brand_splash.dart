import 'dart:async';

import 'package:flutter/material.dart';

import 'onboarding/onboarding_scale.dart';

/// Splash: bus icon moves into slot → text-only wordmark fades in beside it.
class AnimatedBrandSplash extends StatefulWidget {
  const AnimatedBrandSplash({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<AnimatedBrandSplash> createState() => _AnimatedBrandSplashState();
}

class _AnimatedBrandSplashState extends State<AnimatedBrandSplash>
    with SingleTickerProviderStateMixin {
  static const _iconAsset = AssetImage('assets/images/logo_icon.png');
  static const _textAsset = AssetImage('assets/images/logo_text.png');

  // Icon slot measured from logo_full.png (656×193).
  static const _fullAspect = 656 / 193;
  static const _iconLeft = 426 / 656;
  static const _iconWidth = 230 / 656;
  static const _textWidth = 400 / 656;

  late final AnimationController _controller;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    if (!mounted) return;
    await _resolveImage(_iconAsset);
    await _resolveImage(_textAsset);
    if (!mounted) return;
    setState(() => _ready = true);
    await _controller.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (mounted) widget.onFinished();
  }

  Future<void> _resolveImage(ImageProvider provider) async {
    final config = createLocalImageConfiguration(context);
    final stream = provider.resolve(config);
    final completer = Completer<void>();
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (image, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _move(double t) {
    if (t < 0.14) return 0;
    if (t < 0.56) {
      return Curves.easeInOutCubic.transform((t - 0.14) / 0.42);
    }
    return 1;
  }

  /// Text fades in only after the bus icon has landed in its slot.
  double _textOpacity(double t) {
    if (t < 0.56) return 0;
    if (t < 0.76) return Curves.easeOut.transform((t - 0.56) / 0.20);
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    final scale = OnboardingScale(context);
    final fullHeight = scale.s(74);
    final fullWidth = fullHeight * _fullAspect;
    final startIconSize = scale.s(220);
    final endIconWidth = fullWidth * _iconWidth;
    final endIconHeight = fullHeight;
    final endLeft = fullWidth * _iconLeft;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final move = _move(t);

        final iconWidth = startIconSize + (endIconWidth - startIconSize) * move;
        final iconHeight =
            startIconSize + (endIconHeight - startIconSize) * move;

        final startLeft = fullWidth / 2 - startIconSize / 2;
        final startTop = fullHeight / 2 - startIconSize / 2;
        final iconLeft = startLeft + (endLeft - startLeft) * move;
        final iconTop = startTop + (0 - startTop) * move;

        final textOpacity = _textOpacity(t);

        return Center(
          child: SizedBox(
            width: fullWidth,
            height: fullHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: iconLeft,
                  top: iconTop,
                  width: iconWidth,
                  height: iconHeight,
                  child: Image(
                    image: _iconAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
                if (textOpacity > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: fullWidth * _textWidth,
                    height: fullHeight,
                    child: Opacity(
                      opacity: textOpacity,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image(
                          image: _textAsset,
                          height: fullHeight,
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
