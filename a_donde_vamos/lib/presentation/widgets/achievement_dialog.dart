// lib/presentation/widgets/achievement_dialog.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Widget para mostrar alertas personalizadas de logros/insignias desbloqueadas
class AchievementDialog extends StatefulWidget {
  final String badgeName;
  final String badgeDescription;
  final String? badgeIcon;

  const AchievementDialog({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
    this.badgeIcon,
  });

  /// Muestra el diálogo de logro con delay de 3 segundos
  static Future<void> show({
    required BuildContext context,
    required String badgeName,
    required String badgeDescription,
    String? badgeIcon,
    Duration delay = const Duration(seconds: 3),
  }) async {
    await Future.delayed(delay);
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AchievementDialog(
          badgeName: badgeName,
          badgeDescription: badgeDescription,
          badgeIcon: badgeIcon,
        ),
      );
    }
  }

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Animación principal
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Animación de partículas/brillo
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _controller.forward();
    _particleController.repeat();

    // Auto-cerrar después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Partículas brillantes giratorias
              ...List.generate(8, (index) {
                return AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    final distance = 120.0;
                    return Positioned(
                      left:
                          MediaQuery.of(context).size.width / 2 +
                          (distance * (index % 2 == 0 ? 1 : 0.7)) *
                              (index < 4 ? 1 : -1) *
                              0.5,
                      top:
                          MediaQuery.of(context).size.height / 2 +
                          (distance * (index % 2 == 0 ? 0.7 : 1)) *
                              (index % 4 < 2 ? -1 : 1) *
                              0.5,
                      child: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Icons.star,
                          color: [
                            const Color(0xFFFFD700),
                            AppColors.primary,
                            Colors.purple,
                            const Color(0xFFFF1493),
                          ][index % 4],
                          size: 20 + (index % 3) * 5,
                        ),
                      ),
                    );
                  },
                );
              }),

              // Diálogo principal
              Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cardBackground,
                        AppColors.cardBackground.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          '🎉 ¡LOGRO DESBLOQUEADO! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Icono del logro con animación de pulso
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          return Container(
                            width: 100 + (_rotateAnimation.value * 10).abs(),
                            height: 100 + (_rotateAnimation.value * 10).abs(),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.3),
                                  AppColors.cardBackground,
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.6),
                                  blurRadius:
                                      20 + (_rotateAnimation.value * 10),
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Center(
                          child: widget.badgeIcon != null
                              ? Image.network(
                                  widget.badgeIcon!,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 60,
                                        color: AppColors.primary,
                                      ),
                                )
                              : const Icon(
                                  Icons.emoji_events,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nombre del logro
                      Text(
                        widget.badgeName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Descripción
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.badgeDescription,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Botón de cerrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: AppColors.primary.withOpacity(0.5),
                          ),
                          child: const Text(
                            '¡Genial!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
