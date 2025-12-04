// lib/config/supabase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Configuración de Supabase (cargada desde .env)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get serviceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  // Google Maps API
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Stripe (para pagos premium)
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeWebhookSecret => dotenv.env['STRIPE_WEBHOOK_SECRET'] ?? '';

  // Frontend URL
  static String get frontendUrl => dotenv.env['FRONTEND_URL'] ?? '';

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
