// lib/data/services/user_places_service.dart
import '../../config/supabase_config.dart';
import 'supabase_service.dart';

class UserPlacesService {
  final _supabase = SupabaseService.client;

  // Marcar lugar como visitado
  Future<bool> markAsVisited(String placeId, String placeName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from(SupabaseConfig.visitedPlacesTable).upsert({
        'user_id': user.id,
        'place_id': placeId,
        'place_name': placeName,
        'visited_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error marcando como visitado: $e');
      return false;
    }
  }

  // Desmarcar lugar como visitado
  Future<bool> unmarkAsVisited(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from(SupabaseConfig.visitedPlacesTable)
          .delete()
          .eq('user_id', user.id)
          .eq('place_id', placeId);

      return true;
    } catch (e) {
      print('Error desmarcando visitado: $e');
      return false;
    }
  }

  // Verificar si un lugar fue visitado
  Future<bool> isVisited(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.visitedPlacesTable)
          .select()
          .eq('user_id', user.id)
          .eq('place_id', placeId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando visitado: $e');
      return false;
    }
  }

  // Agregar a favoritos
  Future<bool> addToFavorites(String placeId, String placeName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Primero obtener o crear lista de favoritos del usuario
      var favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .eq('name', 'Mis Favoritos')
          .maybeSingle();

      String listId;
      if (favoriteList == null) {
        // Crear lista de favoritos
        final newList = await _supabase
            .from(SupabaseConfig.favoriteListsTable)
            .insert({
              'user_id': user.id,
              'name': 'Mis Favoritos',
              'description': 'Lugares favoritos',
            })
            .select('id')
            .single();
        listId = newList['id'];
      } else {
        listId = favoriteList['id'];
      }

      // Agregar lugar a favoritos
      await _supabase.from(SupabaseConfig.favoritePlacesTable).upsert({
        'list_id': listId,
        'place_id': placeId,
        'place_name': placeName,
        'added_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error agregando a favoritos: $e');
      return false;
    }
  }

  // Quitar de favoritos
  Future<bool> removeFromFavorites(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Obtener lista de favoritos
      final favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .eq('name', 'Mis Favoritos')
          .maybeSingle();

      if (favoriteList == null) return false;

      await _supabase
          .from(SupabaseConfig.favoritePlacesTable)
          .delete()
          .eq('list_id', favoriteList['id'])
          .eq('place_id', placeId);

      return true;
    } catch (e) {
      print('Error quitando de favoritos: $e');
      return false;
    }
  }

  // Verificar si es favorito
  Future<bool> isFavorite(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .eq('name', 'Mis Favoritos')
          .maybeSingle();

      if (favoriteList == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.favoritePlacesTable)
          .select()
          .eq('list_id', favoriteList['id'])
          .eq('place_id', placeId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando favorito: $e');
      return false;
    }
  }

  // Bloquear lugar
  Future<bool> blockPlace(String placeId, String placeName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from(SupabaseConfig.blockedLocationsTable).upsert({
        'user_id': user.id,
        'place_id': placeId,
        'place_name': placeName,
        'blocked_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error bloqueando lugar: $e');
      return false;
    }
  }

  // Desbloquear lugar
  Future<bool> unblockPlace(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from(SupabaseConfig.blockedLocationsTable)
          .delete()
          .eq('user_id', user.id)
          .eq('place_id', placeId);

      return true;
    } catch (e) {
      print('Error desbloqueando lugar: $e');
      return false;
    }
  }

  // Verificar si está bloqueado
  Future<bool> isBlocked(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.blockedLocationsTable)
          .select()
          .eq('user_id', user.id)
          .eq('place_id', placeId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando bloqueado: $e');
      return false;
    }
  }

  // Obtener reseñas de un lugar
  Future<List<Map<String, dynamic>>> getPlaceReviews(String placeId) async {
    try {
      final result = await _supabase
          .from('place_reviews')
          .select('''
            *,
            users:user_id (
              username,
              profile_picture
            )
          ''')
          .eq('place_id', placeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error obteniendo reseñas: $e');
      return [];
    }
  }

  // Agregar reseña
  Future<bool> addReview({
    required String placeId,
    required String placeName,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('place_reviews').insert({
        'user_id': user.id,
        'place_id': placeId,
        'place_name': placeName,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error agregando reseña: $e');
      return false;
    }
  }
}
