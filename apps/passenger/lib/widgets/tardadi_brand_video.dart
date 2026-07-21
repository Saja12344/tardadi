import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const _mp4Path = 'assets/videos/tardadi-icon.mp4';
const _pngFallback = 'assets/images/logo_icon.png';

/// Brand logo video — MP4 for iOS/Android (ProRes MOV is not supported on mobile).
class TardadiBrandVideo extends StatefulWidget {
  const TardadiBrandVideo({
    super.key,
    required this.size,
    this.loop = true,
    this.autoplay = true,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.opacity = 1,
    this.onInitialized,
    this.onFinished,
  });

  final double size;
  final bool loop;
  final bool autoplay;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double opacity;
  final VoidCallback? onInitialized;
  final VoidCallback? onFinished;

  @override
  State<TardadiBrandVideo> createState() => _TardadiBrandVideoState();
}

class _TardadiBrandVideoState extends State<TardadiBrandVideo> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _useFallback = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.asset(_mp4Path);
    _controller = controller;
    try {
      await controller.initialize();
      if (!widget.loop) {
        controller.addListener(_onTick);
      }
      await controller.setLooping(widget.loop);
      if (widget.autoplay) {
        await controller.play();
      }
      if (!mounted) return;
      setState(() => _ready = true);
      widget.onInitialized?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _useFallback = true;
      });
      widget.onInitialized?.call();
      if (!widget.loop) {
        Future<void>.delayed(const Duration(milliseconds: 2200), () {
          if (mounted) widget.onFinished?.call();
        });
      }
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final pos = controller.value.position;
    final dur = controller.value.duration;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 80)) {
      controller.removeListener(_onTick);
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return _wrap(
        Image.asset(
          _pngFallback,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
        ),
      );
    }

    final controller = _controller;
    if (!_ready || controller == null || !controller.value.isInitialized) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final aspect = controller.value.aspectRatio == 0
        ? 1
        : controller.value.aspectRatio;

    return _wrap(
      SizedBox(
        width: widget.size,
        height: widget.size,
        child: FittedBox(
          fit: widget.fit,
          child: SizedBox(
            width: widget.size,
            height: widget.size / aspect,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _wrap(Widget child) {
    Widget result = child;
    if (widget.opacity < 1) {
      result = Opacity(opacity: widget.opacity, child: result);
    }
    if (widget.borderRadius != null) {
      result = ClipRRect(borderRadius: widget.borderRadius!, child: result);
    }
    return result;
  }
}

class TardadiLoading extends StatelessWidget {
  const TardadiLoading({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFF25C2A),
          ),
        ),
      ],
    );
  }
}

/// Full-screen splash: plays brand video once (~2s) then calls [onFinished].
class TardadiSplashVideo extends StatelessWidget {
  const TardadiSplashVideo({
    super.key,
    required this.size,
    required this.onFinished,
  });

  final double size;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    return TardadiBrandVideo(
      size: size,
      loop: false,
      onFinished: onFinished,
    );
  }
}
