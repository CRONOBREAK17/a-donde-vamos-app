// lib/presentation/widgets/video_background.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget que reproduce un video en loop como fondo de pantalla
class VideoBackground extends StatefulWidget {
  final Widget child;
  final String videoPath;
  final double opacity;

  const VideoBackground({
    super.key,
    required this.child,
    this.videoPath = 'assets/videos/background.mp4',
    this.opacity = 0.3,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(0); // Sin sonido
      _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error inicializando video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video de fondo
        if (_isInitialized)
          Positioned.fill(
            child: Opacity(
              opacity: widget.opacity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),

        // Overlay oscuro para mejor legibilidad
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // Contenido principal
        widget.child,
      ],
    );
  }
}
