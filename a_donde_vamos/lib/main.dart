import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/place_detail_screen.dart';
import 'presentation/screens/premium_screen.dart';
import 'data/services/supabase_service.dart';
import 'data/services/ad_service.dart';
import 'data/models/location_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  // Inicializar AdMob
  await AdService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¿A Dónde Vamos?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.auth: (context) => const AuthScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.premium: (context) => const PremiumScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.placeDetail) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(
              place: args['place'] as LocationModel,
              distanceInMeters: args['distance'] as double,
            ),
          );
        }
        return null;
      },
    );
  }
}
