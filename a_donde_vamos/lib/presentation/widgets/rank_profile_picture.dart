// lib/presentation/widgets/rank_profile_picture.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/utils/rank_utils.dart';

/// Widget de foto de perfil con borde animado según el rango del usuario
/// Implementa las mismas animaciones que tu web
class RankProfilePicture extends StatefulWidget {
  final String? imageUrl;
  final int activityPoints;
  final double size;
  final bool showRankEffects;

  const RankProfilePicture({
    super.key,
    this.imageUrl,
    required this.activityPoints,
    this.size = 150,
    this.showRankEffects = true,
  });

  @override
  State<RankProfilePicture> createState() => _RankProfilePictureState();
}

class _RankProfilePictureState extends State<RankProfilePicture>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _lightningController;

  @override
  void initState() {
    super.initState();

    // Animación de pulso (para todos los rangos)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Animación de rotación (para rangos altos)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Animación de rayos (para Leyenda Cósmica)
    _lightningController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankInfo = RankUtils.getRankInfo(widget.activityPoints);

    return Center(
      child: SizedBox(
        width: widget.size + 20,
        height: widget.size + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Efectos de aura para rangos altos
            if (widget.showRankEffects) ...[
              if (rankInfo.className == 'rank-god')
                _buildLeyendaCosmica(rankInfo),
              if (rankInfo.className == 'rank-master')
                _buildViajeroMaestro(rankInfo),
              if (rankInfo.className == 'rank-elite')
                _buildExploradorElite(rankInfo),
            ],

            // Foto de perfil con borde pulsante mejorado
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulseValue = _pulseController.value;
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rankInfo.color,
                      width: 4 + (pulseValue * 2),
                    ),
                    boxShadow: [
                      // Resplandor exterior intenso
                      BoxShadow(
                        color: rankInfo.color.withOpacity(
                          0.6 + (pulseValue * 0.4),
                        ),
                        blurRadius: 25 + (pulseValue * 15),
                        spreadRadius: 5 + (pulseValue * 5),
                      ),
                      // Resplandor medio
                      BoxShadow(
                        color: rankInfo.color.withOpacity(
                          0.4 + (pulseValue * 0.3),
                        ),
                        blurRadius: 15 + (pulseValue * 10),
                        spreadRadius: 3 + (pulseValue * 3),
                      ),
                      // Resplandor cercano
                      BoxShadow(
                        color: rankInfo.color.withOpacity(
                          0.3 + (pulseValue * 0.4),
                        ),
                        blurRadius: 8 + (pulseValue * 6),
                        spreadRadius: 1 + (pulseValue * 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Efecto para LEYENDA CÓSMICA (Magenta con rayos)
  Widget _buildLeyendaCosmica(RankInfo rankInfo) {
    return AnimatedBuilder(
      animation: _lightningController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _lightningController.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size + 20, widget.size + 20),
            painter: LightningBorderPainter(
              color: rankInfo.color,
              progress: _lightningController.value,
            ),
          ),
        );
      },
    );
  }

  // Efecto para VIAJERO MAESTRO (Cyan con aura rotatoria)
  Widget _buildViajeroMaestro(RankInfo rankInfo) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size + 20, widget.size + 20),
            painter: AuraBorderPainter(
              color: rankInfo.color,
              progress: _rotationController.value,
            ),
          ),
        );
      },
    );
  }

  // Efecto para EXPLORADOR ÉLITE (Dorado con brillo sutil)
  Widget _buildExploradorElite(RankInfo rankInfo) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: widget.size + 15,
            height: widget.size + 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rankInfo.color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.person, size: 80, color: Colors.white54),
    );
  }
}

// Painter para efecto de rayos (Leyenda Cósmica)
class LightningBorderPainter extends CustomPainter {
  final Color color;
  final double progress;

  LightningBorderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dibujar líneas verticales y horizontales como rayos
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Sombra brillante
    paint.color = color.withOpacity(0.3);
    paint.strokeWidth = 12;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter para efecto de aura (Viajero Maestro)
class AuraBorderPainter extends CustomPainter {
  final Color color;
  final double progress;

  AuraBorderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Arcos horizontal y vertical
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Sombra brillante
    paint.color = color.withOpacity(0.4);
    paint.strokeWidth = 8;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
