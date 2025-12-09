// lib/data/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_model.dart';
import '../../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  // Obtener usuario actual
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Registro con email y contraseña
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
    String? referralCode,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      // Si el registro fue exitoso, crear perfil en la tabla users
      if (response.user != null) {
        await _createUserProfile(response.user!, referralCode: referralCode);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login con email y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Login con Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.frontendUrl,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener datos del perfil del usuario desde la tabla users
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  // Crear perfil de usuario en la tabla users
  Future<void> _createUserProfile(User user, {String? referralCode}) async {
    try {
      // Verificar si ya existe el perfil
      final existing = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        // Crear nuevo perfil
        await _client.from('users').insert({
          'id': user.id,
          'email': user.email,
          'username':
              user.userMetadata?['username'] ?? user.email?.split('@')[0],
          'created_at': DateTime.now().toIso8601String(),
          'activity_points': 0,
          'is_premium': false,
        });

        // Si hay código de referido, aplicarlo
        if (referralCode != null && referralCode.isNotEmpty) {
          try {
            final result = await _client.rpc(
              'apply_referral_code',
              params: {
                'referred_user_id': user.id,
                'referral_code_input': referralCode.toUpperCase(),
              },
            );

            print('Resultado de aplicar código de referido: $result');
          } catch (e) {
            print('Error al aplicar código de referido: $e');
            // No lanzar error, continuar con el registro
          }
        }
      }
    } catch (e) {
      print('Error al crear perfil: $e');
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? description,
    String? profilePicture,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (description != null) updates['description'] = description;
      if (profilePicture != null) updates['profile_picture'] = profilePicture;

      if (updates.isNotEmpty) {
        await _client.from('users').update(updates).eq('id', userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
