// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Singleton pattern
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado. Llama a initialize() primero.');
    }
    return _client!;
  }

  // Inicializar Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
