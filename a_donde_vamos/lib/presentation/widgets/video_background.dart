// lib/presentation/widgets/video_background.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget que reproduce un video en loop como fondo de pantalla
/// Solo se muestra si activityPoints >= 1000 (Leyenda Cósmica)
class VideoBackground extends StatefulWidget {
  final Widget child;
  final int activityPoints;
  final String videoPath;
  final double opacity;

  const VideoBackground({
    super.key,
    required this.child,
    required this.activityPoints,
    this.videoPath = 'assets/videos/Fondo_De_Pantalla_Neon_Rayos_leyenda.mp4',
    this.opacity = 0.4,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Solo inicializar video si el usuario es Leyenda Cósmica
    if (widget.activityPoints >= 1000) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0); // Sin sonido
      _controller!.play();

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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Solo mostrar video si es Leyenda Cósmica (1000+ puntos)
    final showVideo = widget.activityPoints >= 1000;

    return Stack(
      children: [
        // 1. Fondo oscuro (SIEMPRE presente)
        Positioned.fill(child: Container(color: const Color(0xFF0A0E27))),

        // 2. Video encima del fondo oscuro (SOLO si es Leyenda Cósmica)
        if (showVideo && _isInitialized && _controller != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.7, // Video semi-transparente para que se vea bien
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

        // 3. Overlay oscuro semi-transparente para legibilidad del texto
        if (showVideo && _isInitialized && _controller != null)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(widget.opacity)),
          ),

        // 4. Contenido principal (foto, texto, cards, etc.) - SIEMPRE encima
        widget.child,
      ],
    );
  }
}
