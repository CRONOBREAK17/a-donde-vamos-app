// lib/data/services/user_places_service.dart
import '../../config/supabase_config.dart';
import '../../data/models/location_model.dart';
import 'supabase_service.dart';
import 'badge_service.dart';

class UserPlacesService {
  final _supabase = SupabaseService.client;
  final _badgeService = BadgeService();

  // Crear o actualizar location en la tabla locations
  Future<String?> _ensureLocationExists(LocationModel place) async {
    try {
      // Buscar si ya existe por Google Place ID (usando el name+address como unique)
      final existing = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Crear nuevo location
      final result = await _supabase
          .from(SupabaseConfig.locationsTable)
          .insert({
            'name': place.name,
            'address': place.address,
            'latitude': place.latitude,
            'longitude': place.longitude,
            'google_maps_url': place.googleMapsUrl,
            'average_rating': place.rating ?? 0.0,
            'category': place.types ?? [],
          })
          .select('id')
          .single();

      return result['id'] as String;
    } catch (e) {
      print('Error creando location: $e');
      return null;
    }
  }

  // Marcar lugar como visitado
  Future<Map<String, dynamic>> markAsVisited(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {'success': false};

      final locationId = await _ensureLocationExists(place);
      if (locationId == null) return {'success': false};

      await _supabase.from(SupabaseConfig.visitedPlacesTable).upsert({
        'user_id': user.id,
        'location_id': locationId,
        'location_name': place.name,
        'location_address': place.address,
        'google_maps_url': place.googleMapsUrl,
        'visited_at': DateTime.now().toIso8601String(),
      });

      // Verificar si se debe otorgar alguna insignia
      final badge = await _badgeService.checkAndAwardBadges(
        userId: user.id,
        event: 'first_visit',
      );

      return {'success': true, 'badge': badge};
    } catch (e) {
      print('Error marcando como visitado: $e');
      return {'success': false};
    }
  }

  // Desmarcar lugar como visitado
  Future<bool> unmarkAsVisited(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Buscar location_id
      final location = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (location == null) return false;

      await _supabase
          .from(SupabaseConfig.visitedPlacesTable)
          .delete()
          .eq('user_id', user.id)
          .eq('location_id', location['id']);

      return true;
    } catch (e) {
      print('Error desmarcando visitado: $e');
      return false;
    }
  }

  // Verificar si un lugar fue visitado
  Future<bool> isVisited(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final location = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (location == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.visitedPlacesTable)
          .select()
          .eq('user_id', user.id)
          .eq('location_id', location['id'])
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando visitado: $e');
      return false;
    }
  }

  // Obtener listas de favoritos del usuario
  Future<List<Map<String, dynamic>>> getFavoriteLists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id, name, is_default')
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo listas: $e');
      return [];
    }
  }

  // Agregar a favoritos en lista específica
  Future<bool> addToFavoritesWithList(
    LocationModel place,
    String listId,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final locationId = await _ensureLocationExists(place);
      if (locationId == null) return false;

      // Agregar a favoritos con place_data como jsonb
      await _supabase.from(SupabaseConfig.favoritePlacesTable).insert({
        'list_id': listId,
        'place_id': locationId,
        'place_name': place.name,
        'place_address': place.address,
        'place_data': {
          'google_place_id': place.id,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'rating': place.rating,
          'photo_reference': place.photoReference,
        },
      });

      return true;
    } catch (e) {
      print('Error agregando a favoritos: $e');
      return false;
    }
  }

  // Agregar a favoritos (lista por defecto)
  Future<bool> addToFavorites(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final locationId = await _ensureLocationExists(place);
      if (locationId == null) return false;

      // Obtener o crear lista de favoritos
      var favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .or('is_default.eq.true,name.eq.Mis Favoritos')
          .maybeSingle();

      String listId;
      if (favoriteList == null) {
        final newList = await _supabase
            .from(SupabaseConfig.favoriteListsTable)
            .insert({
              'user_id': user.id,
              'name': 'Mis Favoritos',
              'is_default': true,
            })
            .select('id')
            .single();
        listId = newList['id'];
      } else {
        listId = favoriteList['id'];
      }

      // Agregar a favoritos con place_data como jsonb
      await _supabase.from(SupabaseConfig.favoritePlacesTable).insert({
        'list_id': listId,
        'place_id': locationId,
        'place_name': place.name,
        'place_address': place.address,
        'place_data': {
          'google_place_id': place.id,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'rating': place.rating,
          'photo_reference': place.photoReference,
        },
      });

      return true;
    } catch (e) {
      print('Error agregando a favoritos: $e');
      return false;
    }
  }

  // Quitar de favoritos
  Future<bool> removeFromFavorites(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final location = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (location == null) return false;

      final favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .or('is_default.eq.true,name.eq.Mis Favoritos')
          .maybeSingle();

      if (favoriteList == null) return false;

      await _supabase
          .from(SupabaseConfig.favoritePlacesTable)
          .delete()
          .eq('list_id', favoriteList['id'])
          .eq('place_id', location['id']);

      return true;
    } catch (e) {
      print('Error quitando de favoritos: $e');
      return false;
    }
  }

  // Verificar si es favorito
  Future<bool> isFavorite(LocationModel place) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final location = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (location == null) return false;

      final favoriteList = await _supabase
          .from(SupabaseConfig.favoriteListsTable)
          .select('id')
          .eq('user_id', user.id)
          .or('is_default.eq.true,name.eq.Mis Favoritos')
          .maybeSingle();

      if (favoriteList == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.favoritePlacesTable)
          .select()
          .eq('list_id', favoriteList['id'])
          .eq('place_id', location['id'])
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando favorito: $e');
      return false;
    }
  }

  // Bloquear lugar (usa location_id text para Google Place ID)
  Future<bool> blockPlace(String googlePlaceId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from(SupabaseConfig.blockedLocationsTable).upsert({
        'user_id': user.id,
        'location_id': googlePlaceId,
        'blocked_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error bloqueando lugar: $e');
      return false;
    }
  }

  // Desbloquear lugar
  Future<bool> unblockPlace(String googlePlaceId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from(SupabaseConfig.blockedLocationsTable)
          .delete()
          .eq('user_id', user.id)
          .eq('location_id', googlePlaceId);

      return true;
    } catch (e) {
      print('Error desbloqueando lugar: $e');
      return false;
    }
  }

  // Verificar si está bloqueado
  Future<bool> isBlocked(String googlePlaceId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final result = await _supabase
          .from(SupabaseConfig.blockedLocationsTable)
          .select()
          .eq('user_id', user.id)
          .eq('location_id', googlePlaceId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error verificando bloqueado: $e');
      return false;
    }
  }

  // Obtener reseñas de un lugar (de la tabla reviews)
  Future<List<Map<String, dynamic>>> getPlaceReviews(
    LocationModel place,
  ) async {
    try {
      final location = await _supabase
          .from(SupabaseConfig.locationsTable)
          .select('id')
          .eq('name', place.name)
          .eq('address', place.address)
          .maybeSingle();

      if (location == null) return [];

      final result = await _supabase
          .from(SupabaseConfig.reviewsTable)
          .select('''
            *,
            users:user_id (
              username,
              name,
              profile_picture
            )
          ''')
          .eq('location_id', location['id'])
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error obteniendo reseñas: $e');
      return [];
    }
  }

  // Agregar reseña
  Future<bool> addReview({
    required LocationModel place,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final locationId = await _ensureLocationExists(place);
      if (locationId == null) return false;

      await _supabase.from(SupabaseConfig.reviewsTable).insert({
        'user_id': user.id,
        'location_id': locationId,
        'rating': rating,
        'comment': comment,
      });

      return true;
    } catch (e) {
      print('Error agregando reseña: $e');
      return false;
    }
  }
}
