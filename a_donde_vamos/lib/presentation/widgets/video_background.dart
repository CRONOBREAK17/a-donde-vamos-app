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
  String _debugStatus = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    debugPrint('🎥 VideoBackground initState()');
    debugPrint('🎥 Activity Points: ${widget.activityPoints}');
    debugPrint('🎥 Video Path: ${widget.videoPath}');

    // Solo inicializar video si el usuario es Leyenda Cósmica
    if (widget.activityPoints >= 1000) {
      debugPrint('🎥 ✅ Usuario es Leyenda Cósmica! Iniciando video...');
      _initializeVideo();
    } else {
      debugPrint('🎥 ❌ Usuario NO es Leyenda Cósmica (necesita 1000+ pts)');
      _debugStatus = 'No cumple requisitos de puntos';
    }
  }

  Future<void> _initializeVideo() async {
    debugPrint('🎥 Intentando inicializar video...');
    try {
      _debugStatus = 'Creando controller...';
      debugPrint('🎥 Creando VideoPlayerController con: ${widget.videoPath}');
      _controller = VideoPlayerController.asset(widget.videoPath);

      _debugStatus = 'Inicializando controller...';
      debugPrint('🎥 Llamando a _controller.initialize()...');
      await _controller!.initialize();

      debugPrint('🎥 ✅ Video inicializado exitosamente!');
      debugPrint(
        '🎥 Tamaño del video: ${_controller!.value.size.width}x${_controller!.value.size.height}',
      );
      debugPrint('🎥 Duración: ${_controller!.value.duration}');

      _controller!.setLooping(true);
      _controller!.setVolume(0); // Sin sonido
      _controller!.play();

      debugPrint('🎥 Video configurado: loop=true, volumen=0, playing...');

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _debugStatus = 'Video listo!';
        });
        debugPrint('🎥 setState() llamado - _isInitialized = true');
      }
    } catch (e, stackTrace) {
      _debugStatus = 'ERROR: $e';
      debugPrint('🎥 ❌ ERROR inicializando video: $e');
      debugPrint('🎥 StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    debugPrint('🎥 VideoBackground dispose()');
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Solo mostrar video si es Leyenda Cósmica (1000+ puntos)
    final showVideo = widget.activityPoints >= 1000;

    debugPrint(
      '🎥 BUILD - showVideo: $showVideo, _isInitialized: $_isInitialized, _controller != null: ${_controller != null}',
    );
    debugPrint('🎥 Status: $_debugStatus');

    return Stack(
      children: [
        // 1. Fondo oscuro (SIEMPRE presente)
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0A0E27),
            child: Center(
              child: Text(
                'DEBUG: $_debugStatus\nPoints: ${widget.activityPoints}\nVideo: $showVideo\nInit: $_isInitialized',
                style: const TextStyle(color: Colors.red, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

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
