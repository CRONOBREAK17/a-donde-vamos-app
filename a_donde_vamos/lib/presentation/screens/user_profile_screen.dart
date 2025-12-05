// lib/presentation/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import '../widgets/rank_profile_picture.dart';
import 'achievements_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String _username = '';
  String _description = '';
  int _activityPoints = 0;
  String? _profilePicture;
  List<Map<String, dynamic>> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Cargar datos del usuario
      final response = await _supabase
          .from('users')
          .select('username, description, activity_points, profile_picture')
          .eq('id', widget.userId)
          .single();

      // Cargar insignias
      final badgesResponse = await _supabase
          .from('user_badges')
          .select(
            'awarded_at, badge:badges_list(name, description, criteria, icon_url)',
          )
          .eq('user_id', widget.userId)
          .order('awarded_at', ascending: false);

      setState(() {
        _username = response['username'] as String? ?? '';
        _description = response['description'] as String? ?? '';
        _activityPoints = response['activity_points'] as int? ?? 0;
        _profilePicture = response['profile_picture'] as String?;
        _badges = List<Map<String, dynamic>>.from(badgesResponse);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.cardBackground),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final rankInfo = RankUtils.getRankInfo(_activityPoints);
    final nextRank = RankUtils.getNextRank(_activityPoints);
    final progress = RankUtils.getProgressToNextRank(_activityPoints);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_username),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Foto de perfil con animación de rango
            RankProfilePicture(
              imageUrl: _profilePicture,
              activityPoints: _activityPoints,
              size: 150,
            ),

            const SizedBox(height: 20),

            // Nombre de usuario
            Text(
              _username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Rango
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: rankInfo.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rankInfo.color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rankInfo.color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                rankInfo.title,
                style: TextStyle(
                  color: rankInfo.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Puntos de actividad
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: rankInfo.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⭐ Puntos de actividad',
                        style: TextStyle(
                          color: rankInfo.color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_activityPoints pts',
                        style: TextStyle(
                          color: rankInfo.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (nextRank != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[800],
                        color: rankInfo.color,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Siguiente: ${nextRank.title} (${nextRank.minPoints} pts)',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Biografía
            if (_description.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: rankInfo.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Biografía',
                      style: TextStyle(
                        color: rankInfo.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Botón para ver logros
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rankInfo.color.withOpacity(0.3),
                    rankInfo.color.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: rankInfo.color.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rankInfo.color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AchievementsScreen(
                              badges: _badges,
                              activityPoints: _activityPoints,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Icono
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [const Color(0xFFFFD700), rankInfo.color],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: rankInfo.color.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Texto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🏆 Ver Logros',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_badges.length} ${_badges.length == 1 ? "logro" : "logros"}',
                                style: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Flecha
                        Icon(
                          Icons.arrow_forward_ios,
                          color: rankInfo.color.withOpacity(0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
