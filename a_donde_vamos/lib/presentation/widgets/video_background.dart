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

    print('═════════════════════════════════════');
    print('🎥 VideoBackground BUILD');
    print('🎥 Activity Points: ${widget.activityPoints}');
    print('🎥 showVideo: $showVideo (necesita >= 1000)');
    print('🎥 _isInitialized: $_isInitialized');
    print('🎥 _controller != null: ${_controller != null}');
    print('🎥 Status: $_debugStatus');
    print('═════════════════════════════════════');

    return Stack(
      children: [
        // 1. Fondo oscuro (SIEMPRE presente)
        Positioned.fill(child: Container(color: const Color(0xFF0A0E27))),

        // DEBUG: Info visible en pantalla
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            color: Colors.black.withOpacity(0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎥 VIDEO DEBUG',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Points: ${widget.activityPoints}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Show Video: $showVideo',
                  style: TextStyle(
                    color: showVideo ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Initialized: $_isInitialized',
                  style: TextStyle(
                    color: _isInitialized ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Controller: ${_controller != null}',
                  style: TextStyle(
                    color: _controller != null ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Status: $_debugStatus',
                  style: const TextStyle(color: Colors.cyan, fontSize: 11),
                ),
                if (_controller != null && _isInitialized)
                  Text(
                    'Video: ${_controller!.value.size.width}x${_controller!.value.size.height}',
                    style: const TextStyle(color: Colors.lime, fontSize: 11),
                  ),
              ],
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
