// lib/data/services/badge_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

/// Servicio para gestionar insignias y logros del usuario
class BadgeService {
  final _supabase = Supabase.instance.client;

  /// Verifica y otorga insignias basadas en la actividad del usuario
  Future<Map<String, dynamic>?> checkAndAwardBadges({
    required String userId,
    String? event,
  }) async {
    try {
      // Obtener estadísticas del usuario
      final stats = await _getUserStats(userId);

      print('📊 Estadísticas del usuario: $stats');

      // Lista de insignias a verificar
      Map<String, dynamic>? newBadge;

      // ============ LOGROS POR VISITAS ============
      // ID 1: El Principiante - 1 lugar
      if (stats['visited_count'] == 1) {
        print('🎯 Primera visita detectada, otorgando insignia...');
        newBadge = await _awardBadge(userId, 1);
      }
      // ID 45: Pequeño Explorador - 2 lugares
      else if (stats['visited_count'] == 2) {
        newBadge = await _awardBadge(userId, 45);
      }
      // ID 2: Explorador Novato - 5 lugares
      else if (stats['visited_count'] == 5) {
        newBadge = await _awardBadge(userId, 2);
      }
      // ID 3: Viajero Frecuente - 10 lugares
      else if (stats['visited_count'] == 10) {
        newBadge = await _awardBadge(userId, 3);
      }
      // ID 46: Explorador Consolidado - 15 lugares
      else if (stats['visited_count'] == 15) {
        newBadge = await _awardBadge(userId, 46);
      }
      // ID 12: Conquistador de Tipos - 20 lugares
      else if (stats['visited_count'] == 20) {
        newBadge = await _awardBadge(userId, 12);
      }
      // ID 4: Buscador Infatigable - 25 lugares
      else if (stats['visited_count'] == 25) {
        newBadge = await _awardBadge(userId, 4);
      }
      // ID 47: Explorador Experto - 35 lugares
      else if (stats['visited_count'] == 35) {
        newBadge = await _awardBadge(userId, 47);
      }
      // ID 5: Maestro Cartógrafo - 50 lugares
      else if (stats['visited_count'] == 50) {
        newBadge = await _awardBadge(userId, 5);
      }
      // ID 48: Explorador Supremo - 75 lugares
      else if (stats['visited_count'] == 75) {
        newBadge = await _awardBadge(userId, 48);
      }
      // ID 6: Leyenda de la Exploración - 100 lugares
      else if (stats['visited_count'] == 100) {
        newBadge = await _awardBadge(userId, 6);
      }
      // ID 7: Veterano - 200 lugares
      else if (stats['visited_count'] == 200) {
        newBadge = await _awardBadge(userId, 7);
      }

      // ============ LOGROS POR PUNTOS ============
      // ID 36: El Ahorrador - 500 puntos
      if (stats['activity_points'] >= 500 && stats['activity_points'] < 1000) {
        final badge = await _awardBadge(userId, 36);
        if (badge != null) newBadge = badge;
      }
      // ID 37: El Millonario de Puntos - 1000 puntos
      else if (stats['activity_points'] >= 1000 &&
          stats['activity_points'] < 2000) {
        final badge = await _awardBadge(userId, 37);
        if (badge != null) newBadge = badge;
      }
      // ID 38: Coleccionista de Puntos - 2000 puntos
      else if (stats['activity_points'] >= 2000 &&
          stats['activity_points'] < 5000) {
        final badge = await _awardBadge(userId, 38);
        if (badge != null) newBadge = badge;
      }
      // ID 39: Acelerador de Puntos - 5000 puntos
      else if (stats['activity_points'] >= 5000) {
        final badge = await _awardBadge(userId, 39);
        if (badge != null) newBadge = badge;
      }

      return newBadge;
    } catch (e) {
      print('Error verificando insignias: $e');
      return null;
    }
  }

  /// Obtiene las estadísticas del usuario
  Future<Map<String, int>> _getUserStats(String userId) async {
    try {
      // Contar lugares visitados
      final visitedResponse = await _supabase
          .from(SupabaseConfig.visitedPlacesTable)
          .select()
          .eq('user_id', userId);
      final visitedCount = visitedResponse.length;

      // Obtener puntos de actividad del usuario
      final userResponse = await _supabase
          .from('users')
          .select('activity_points')
          .eq('id', userId)
          .single();
      final activityPoints = userResponse['activity_points'] as int? ?? 0;

      print('📊 Stats - Visitados: $visitedCount, Puntos: $activityPoints');

      return {'visited_count': visitedCount, 'activity_points': activityPoints};
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {'visited_count': 0, 'activity_points': 0};
    }
  }

  /// Otorga una insignia al usuario si no la tiene
  Future<Map<String, dynamic>?> _awardBadge(String userId, int badgeId) async {
    try {
      print('🏅 Intentando otorgar insignia $badgeId al usuario $userId');

      // Verificar si ya tiene la insignia
      final existing = await _supabase
          .from('user_badges')
          .select('id')
          .eq('user_id', userId)
          .eq('badge_id', badgeId)
          .maybeSingle();

      if (existing != null) {
        print('⚠️ Usuario ya tiene esta insignia');
        return null; // Ya tiene la insignia
      }

      // Obtener información de la insignia
      final badge = await _supabase
          .from('badges_list')
          .select('id, name, description, icon_url, points_reward')
          .eq('id', badgeId)
          .single();

      print('🎖️ Insignia encontrada: ${badge['name']}');

      // Otorgar la insignia
      await _supabase.from('user_badges').insert({
        'user_id': userId,
        'badge_id': badge['id'],
        'awarded_at': DateTime.now().toIso8601String(),
      });

      print('✅ Insignia otorgada exitosamente');

      // Incrementar puntos de actividad (puntos de la insignia)
      final pointsReward = badge['points_reward'] as int? ?? 0;
      print('💰 Puntos a otorgar: $pointsReward');

      if (pointsReward > 0) {
        final userResponse = await _supabase
            .from('users')
            .select('activity_points')
            .eq('id', userId)
            .single();

        final currentPoints = userResponse['activity_points'] as int? ?? 0;

        await _supabase
            .from('users')
            .update({'activity_points': currentPoints + pointsReward})
            .eq('id', userId);

        print(
          '✨ Puntos actualizados: $currentPoints → ${currentPoints + pointsReward}',
        );
      }

      final result = {
        'name': badge['name'],
        'description': badge['description'],
        'icon_url': badge['icon_url'],
      };

      print('🎉 Retornando insignia: $result');
      return result;
    } catch (e) {
      print('Error otorgando insignia: $e');
      return null;
    }
  }

  /// Obtiene todas las insignias de un usuario
  Future<List<Map<String, dynamic>>> getUserBadges(String userId) async {
    try {
      final response = await _supabase
          .from('user_badges')
          .select('''
            awarded_at,
            badge:badges_list(id, name, description, icon_url)
          ''')
          .eq('user_id', userId)
          .order('awarded_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo insignias: $e');
      return [];
    }
  }
}
