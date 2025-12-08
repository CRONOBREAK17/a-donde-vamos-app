// lib/presentation/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import 'user_profile_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  List<Map<String, dynamic>> _topUsers = [];
  int _limit = 50;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('users')
          .select('id, username, profile_picture, activity_points, is_premium')
          .order('activity_points', ascending: false)
          .limit(_limit);

      setState(() {
        _topUsers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading ranking: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏆 Ranking'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _limit = value);
              _loadRanking();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 10, child: Text('Top 10')),
              const PopupMenuItem(value: 25, child: Text('Top 25')),
              const PopupMenuItem(value: 50, child: Text('Top 50')),
              const PopupMenuItem(value: 100, child: Text('Top 100')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topUsers.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRanking,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _topUsers.length,
                itemBuilder: (context, index) {
                  final user = _topUsers[index];
                  return _buildRankCard(user, index + 1);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          'No hay usuarios en el ranking',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> user, int position) {
    final username = user['username'] as String? ?? 'Usuario';
    final profilePic = user['profile_picture'] as String?;
    final activityPoints = user['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);

    // Colores especiales para top 3
    Color positionColor;
    IconData positionIcon;
    if (position == 1) {
      positionColor = const Color(0xFFFFD700); // Oro
      positionIcon = Icons.emoji_events;
    } else if (position == 2) {
      positionColor = const Color(0xFFC0C0C0); // Plata
      positionIcon = Icons.emoji_events;
    } else if (position == 3) {
      positionColor = const Color(0xFFCD7F32); // Bronce
      positionIcon = Icons.emoji_events;
    } else {
      positionColor = AppColors.textMuted;
      positionIcon = Icons.person;
    }

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: position <= 3
              ? positionColor.withOpacity(0.5)
              : rankInfo.color.withOpacity(0.3),
          width: position <= 3 ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: positionColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (position <= 3)
                    Icon(positionIcon, color: positionColor, size: 16),
                  Text(
                    '#$position',
                    style: TextStyle(
                      color: positionColor,
                      fontWeight: FontWeight.bold,
                      fontSize: position <= 3 ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Foto de perfil con borde de rango
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankInfo.color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rankInfo.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic)
                    : null,
                child: profilePic == null
                    ? Text(
                        username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: rankInfo.color,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            _buildPremiumBadge(user['is_premium'] as bool? ?? false),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rankInfo.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rankInfo.color.withOpacity(0.5)),
              ),
              child: Text(
                rankInfo.title,
                style: TextStyle(
                  color: rankInfo.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '⭐ $activityPoints puntos',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: user['id']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumBadge(bool isPremium) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 10, color: Colors.black),
            SizedBox(width: 3),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        child: const Text(
          'GRATUITO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }
}
