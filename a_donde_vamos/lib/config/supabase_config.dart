// lib/config/supabase_config.dart

class SupabaseConfig {
  // Configuración de Supabase
  static String get supabaseUrl => 'https://aukzmohxmqvgqrfporwg.supabase.co';

  // Anon key actualizada (válida hasta 2035)
  static String get supabaseAnonKey =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1a3ptb2h4bXF2Z3FyZnBvcndnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MTMyNDQsImV4cCI6MjA2OTk4OTI0NH0.RCb9r1Ay0SzkYdJpBpb-Yi_OcD00B8ZXh50TsCNIPLw';

  // Secret key - NO usar en frontend, solo para referencia
  static String get serviceRoleKey =>
      'sb_secret_96D1ppVkjT5J_4ScObed_w_ZNl5QEPs';

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
