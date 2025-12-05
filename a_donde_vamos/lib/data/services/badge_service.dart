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

      // Lista de insignias a verificar
      Map<String, dynamic>? newBadge;

      // Primera visita
      if (event == 'first_visit' && stats['visited_count'] == 1) {
        newBadge = await _awardBadge(userId, 'primer_explorador');
      }

      // 5 lugares visitados
      if (stats['visited_count'] == 5) {
        newBadge = await _awardBadge(userId, 'explorador_novato');
      }

      // 10 lugares visitados
      if (stats['visited_count'] == 10) {
        newBadge = await _awardBadge(userId, 'viajero_frecuente');
      }

      // 25 lugares visitados
      if (stats['visited_count'] == 25) {
        newBadge = await _awardBadge(userId, 'maestro_exploracion');
      }

      // 50 lugares visitados
      if (stats['visited_count'] == 50) {
        newBadge = await _awardBadge(userId, 'leyenda_viajera');
      }

      // Primer lugar favorito
      if (event == 'first_favorite' && stats['favorite_count'] == 1) {
        newBadge = await _awardBadge(userId, 'coleccionista');
      }

      // Primer amigo
      if (event == 'first_friend' && stats['friend_count'] == 1) {
        newBadge = await _awardBadge(userId, 'social');
      }

      // 5 amigos
      if (stats['friend_count'] == 5) {
        newBadge = await _awardBadge(userId, 'popular');
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

      // Contar favoritos
      final favoriteResponse = await _supabase
          .from('favorite_places')
          .select()
          .eq('user_id', userId);
      final favoriteCount = favoriteResponse.length;

      // Contar amigos
      final friendResponse = await _supabase
          .from('user_friends')
          .select()
          .eq('user_id', userId);
      final friendCount = friendResponse.length;

      return {
        'visited_count': visitedCount,
        'favorite_count': favoriteCount,
        'friend_count': friendCount,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {'visited_count': 0, 'favorite_count': 0, 'friend_count': 0};
    }
  }

  /// Otorga una insignia al usuario si no la tiene
  Future<Map<String, dynamic>?> _awardBadge(
    String userId,
    String badgeCode,
  ) async {
    try {
      // Verificar si ya tiene la insignia
      final existing = await _supabase
          .from('user_badges')
          .select('id')
          .eq('user_id', userId)
          .eq('badge_id', badgeCode)
          .maybeSingle();

      if (existing != null) return null; // Ya tiene la insignia

      // Obtener información de la insignia
      final badge = await _supabase
          .from('badges_list')
          .select('id, name, description, icon_url')
          .eq('id', badgeCode)
          .single();

      // Otorgar la insignia
      await _supabase.from('user_badges').insert({
        'user_id': userId,
        'badge_id': badge['id'],
        'awarded_at': DateTime.now().toIso8601String(),
      });

      // Incrementar puntos de actividad
      await _supabase.rpc(
        'increment_activity_points',
        params: {
          'user_id': userId,
          'points': 50, // 50 puntos por cada insignia
        },
      );

      return {
        'name': badge['name'],
        'description': badge['description'],
        'icon_url': badge['icon_url'],
      };
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
