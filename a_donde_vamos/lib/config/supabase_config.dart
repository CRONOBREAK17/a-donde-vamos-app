// lib/config/supabase_config.dart

class SupabaseConfig {
  // Configuración de Supabase
  static String get supabaseUrl => 'https://aukzmohxmqvgqrfporwg.supabase.co';
  static String get supabaseAnonKey =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1a3ptb2h4bXF2Z3FyZnBvcndnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyNjk2MjYsImV4cCI6MjA0ODg0NTYyNn0.mEE4dkeL2e_yJqOJg2Qh9SG6Qb18XQWyJZIBTwdwz58';
  static String get serviceRoleKey =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1a3ptb2h4bXF2Z3FyZnBvcndnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMzI2OTYyNiwiZXhwIjoyMDQ4ODQ1NjI2fQ.DZMGdpg_Kv3qNMt1cSxEQ5yKJVIUBJVOlkvJ1u_y7Q0';

  // Google Maps API
  static String get googleMapsApiKey =>
      'AIzaSyB8qeOmj_KuX_OMtJ__MDtC-PL9hk6voDM';

  // Stripe (para pagos premium)
  static String get stripePublishableKey => 'pk_test_xxxxx';
  static String get stripeWebhookSecret => 'whsec_xxxxx';

  // Frontend URL
  static String get frontendUrl => 'https://a-donde-vamos-omega.vercel.app';

  // Nombres de tablas (según tu esquema)
  static const String usersTable = 'users';
  static const String locationsTable = 'locations';
  static const String visitedPlacesTable = 'user_visited_places';
  static const String favoriteListsTable = 'favorite_lists';
  static const String favoritePlacesTable = 'favorite_places';
  static const String blockedLocationsTable = 'user_blocked_locations';
  static const String badgesTable = 'badges_list';
  static const String userBadgesTable = 'user_badges';
  static const String reviewsTable = 'reviews';
  static const String reviewVotesTable = 'review_votes';
  static const String userFriendsTable = 'user_friends';
  static const String photosTable = 'photos';
  static const String currentDestinationTable = 'user_current_destination';
  static const String pendingLocationsTable = 'user_pending_locations';
}
