// lib/data/services/referral_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ReferralService {
  final _supabase = Supabase.instance.client;

  /// Obtiene el código de referido del usuario actual
  Future<String?> getUserReferralCode() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('referral_code')
          .eq('id', user.id)
          .single();

      return response['referral_code'] as String?;
    } catch (e) {
      print('Error obteniendo código de referido: $e');
      return null;
    }
  }

  /// Aplica un código de referido para el usuario actual
  Future<Map<String, dynamic>> applyReferralCode(String code) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No hay usuario autenticado'};
      }

      final response = await _supabase.rpc(
        'apply_referral_code',
        params: {
          'referred_user_id': user.id,
          'referral_code_input': code.toUpperCase(),
        },
      );

      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      print('Error aplicando código de referido: $e');
      return {'success': false, 'message': 'Error al aplicar el código: $e'};
    }
  }

  /// Obtiene estadísticas de referidos del usuario
  Future<Map<String, dynamic>?> getReferralStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase.rpc(
        'get_referral_stats',
        params: {'user_id_input': user.id},
      );

      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      print('Error obteniendo estadísticas de referidos: $e');
      return null;
    }
  }

  /// Obtiene la lista de usuarios referidos
  Future<List<Map<String, dynamic>>> getReferredUsers() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('referrals')
          .select('''
            id,
            created_at,
            points_awarded,
            referred_id,
            users!referrals_referred_id_fkey(username, profile_picture)
          ''')
          .eq('referrer_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error obteniendo usuarios referidos: $e');
      return [];
    }
  }

  /// Verifica si el usuario actual ha sido referido
  Future<bool> hasBeenReferred() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('users')
          .select('referred_by')
          .eq('id', user.id)
          .single();

      return response['referred_by'] != null;
    } catch (e) {
      print('Error verificando referido: $e');
      return false;
    }
  }

  /// Obtiene información del referrer (quien invitó al usuario actual)
  Future<Map<String, dynamic>?> getReferrerInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('''
            referred_by,
            referrer:users!users_referred_by_fkey(
              username,
              profile_picture
            )
          ''')
          .eq('id', user.id)
          .single();

      if (response['referred_by'] == null) return null;

      return response['referrer'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error obteniendo info del referrer: $e');
      return null;
    }
  }

  /// Genera mensaje para compartir código de referido
  String generateShareMessage(String referralCode) {
    return '''
🎉 ¡Únete a "¿A Dónde Vamos?" conmigo!

Usa mi código de referido: $referralCode

Descubre lugares increíbles cerca de ti y gana puntos. 
¡Ambos recibiremos recompensas! 🚀

Descarga la app aquí: [LINK_DE_TU_APP]
    '''
        .trim();
  }
}
