// lib/data/services/friendship_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para gestionar solicitudes de amistad y amigos
class FriendshipService {
  final _supabase = Supabase.instance.client;

  /// Estados de solicitud de amistad
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';

  /// Enviar solicitud de amistad
  Future<Map<String, dynamic>> sendFriendRequest(String friendId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      if (user.id == friendId) {
        return {'success': false, 'message': 'No puedes agregarte a ti mismo'};
      }

      // Verificar si ya existe una solicitud o amistad
      final existing = await _supabase
          .from('user_friends')
          .select()
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}')
          .or('user_id.eq.$friendId,friend_id.eq.$friendId')
          .maybeSingle();

      if (existing != null) {
        if (existing['status'] == statusAccepted) {
          return {'success': false, 'message': 'Ya son amigos'};
        } else if (existing['status'] == statusPending) {
          return {'success': false, 'message': 'Solicitud pendiente'};
        }
      }

      // Crear solicitud (solo una dirección, de sender a receiver)
      await _supabase.from('user_friends').insert({
        'user_id': user.id,
        'friend_id': friendId,
        'status': statusPending,
      });

      return {'success': true, 'message': 'Solicitud enviada'};
    } catch (e) {
      print('Error enviando solicitud: $e');
      return {'success': false, 'message': 'Error al enviar solicitud'};
    }
  }

  /// Aceptar solicitud de amistad
  Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      // Obtener datos de la solicitud
      final request = await _supabase
          .from('user_friends')
          .select()
          .eq('id', requestId)
          .eq('friend_id', user.id)
          .eq('status', statusPending)
          .single();

      final senderId = request['user_id'] as String;

      // Actualizar la solicitud existente a accepted
      await _supabase
          .from('user_friends')
          .update({'status': statusAccepted})
          .eq('id', requestId);

      // Crear la relación inversa también como accepted
      await _supabase.from('user_friends').insert({
        'user_id': user.id,
        'friend_id': senderId,
        'status': statusAccepted,
      });

      return {'success': true, 'message': 'Solicitud aceptada'};
    } catch (e) {
      print('Error aceptando solicitud: $e');
      return {'success': false, 'message': 'Error al aceptar solicitud'};
    }
  }

  /// Rechazar solicitud de amistad
  Future<Map<String, dynamic>> rejectFriendRequest(String requestId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      await _supabase
          .from('user_friends')
          .update({'status': statusRejected})
          .eq('id', requestId)
          .eq('friend_id', user.id);

      return {'success': true, 'message': 'Solicitud rechazada'};
    } catch (e) {
      print('Error rechazando solicitud: $e');
      return {'success': false, 'message': 'Error al rechazar solicitud'};
    }
  }

  /// Cancelar solicitud enviada
  Future<Map<String, dynamic>> cancelFriendRequest(String requestId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      await _supabase
          .from('user_friends')
          .delete()
          .eq('id', requestId)
          .eq('user_id', user.id)
          .eq('status', statusPending);

      return {'success': true, 'message': 'Solicitud cancelada'};
    } catch (e) {
      print('Error cancelando solicitud: $e');
      return {'success': false, 'message': 'Error al cancelar solicitud'};
    }
  }

  /// Obtener solicitudes recibidas (entrantes)
  Future<List<Map<String, dynamic>>> getIncomingRequests() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('user_friends')
          .select(
            'id, created_at, sender:users!user_friends_user_id_fkey(id, username, profile_picture, activity_points)',
          )
          .eq('friend_id', user.id)
          .eq('status', statusPending)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo solicitudes entrantes: $e');
      return [];
    }
  }

  /// Obtener solicitudes enviadas (pendientes)
  Future<List<Map<String, dynamic>>> getOutgoingRequests() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('user_friends')
          .select(
            'id, created_at, receiver:users!user_friends_friend_id_fkey(id, username, profile_picture, activity_points)',
          )
          .eq('user_id', user.id)
          .eq('status', statusPending)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo solicitudes enviadas: $e');
      return [];
    }
  }

  /// Obtener amigos confirmados
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('user_friends')
          .select(
            'friend:users!user_friends_friend_id_fkey(id, username, profile_picture, activity_points)',
          )
          .eq('user_id', user.id)
          .eq('status', statusAccepted)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        response.map((item) => item['friend'] as Map<String, dynamic>),
      );
    } catch (e) {
      print('Error obteniendo amigos: $e');
      return [];
    }
  }

  /// Eliminar amigo
  Future<Map<String, dynamic>> removeFriend(String friendId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      // Eliminar ambas direcciones de la amistad (donde status = 'accepted')
      await _supabase
          .from('user_friends')
          .delete()
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}')
          .or('user_id.eq.$friendId,friend_id.eq.$friendId')
          .eq('status', statusAccepted);

      return {'success': true, 'message': 'Amigo eliminado'};
    } catch (e) {
      print('Error eliminando amigo: $e');
      return {'success': false, 'message': 'Error al eliminar amigo'};
    }
  }

  /// Verificar estado de amistad con un usuario
  Future<String> checkFriendshipStatus(String userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'none';

      if (user.id == userId) return 'self';

      // Verificar si son amigos (status = 'accepted')
      final friendship = await _supabase
          .from('user_friends')
          .select()
          .eq('user_id', user.id)
          .eq('friend_id', userId)
          .eq('status', statusAccepted)
          .maybeSingle();

      if (friendship != null) return 'friends';

      // Verificar solicitudes pendientes (status = 'pending')
      final request = await _supabase
          .from('user_friends')
          .select()
          .or('user_id.eq.${user.id},friend_id.eq.${user.id}')
          .or('user_id.eq.$userId,friend_id.eq.$userId')
          .eq('status', statusPending)
          .maybeSingle();

      if (request != null) {
        if (request['user_id'] == user.id) {
          return 'request_sent';
        } else {
          return 'request_received';
        }
      }

      return 'none';
    } catch (e) {
      print('Error verificando estado: $e');
      return 'none';
    }
  }

  /// Buscar usuarios para agregar como amigos
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      if (query.trim().isEmpty) return [];

      final response = await _supabase
          .from('users')
          .select('id, username, profile_picture, activity_points')
          .neq('id', user.id) // Excluir usuario actual
          .ilike('username', '%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error buscando usuarios: $e');
      return [];
    }
  }
}
