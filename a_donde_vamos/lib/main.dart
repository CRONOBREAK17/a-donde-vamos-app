import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/providers/settings_provider.dart';
import 'core/localization/app_localizations.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/place_detail_screen.dart';
import 'presentation/screens/premium_screen.dart';
import 'presentation/screens/settings_screen.dart';
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
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const AppContent(),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: '¿A Dónde Vamos?',
          debugShowCheckedModeBanner: false,

          // Tema
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,

          // Localización
          locale: settingsProvider.locale,
          supportedLocales: const [
            Locale('es', 'MX'), // México
            Locale('en', 'US'), // English
            Locale('es', 'ES'), // España
            Locale('es', 'AR'), // Argentina
            Locale('es', 'CL'), // Chile
            Locale('es', 'CO'), // Colombia
            Locale('es', 'PE'), // Perú
            Locale('es', 'VE'), // Venezuela
            Locale('es', 'EC'), // Ecuador
            Locale('es', 'BO'), // Bolivia
            Locale('es', 'PY'), // Paraguay
            Locale('es', 'UY'), // Uruguay
            Locale('es', 'CR'), // Costa Rica
            Locale('es', 'PA'), // Panamá
            Locale('es', 'CU'), // Cuba
            Locale('es', 'DO'), // República Dominicana
            Locale('es', 'PR'), // Puerto Rico
            Locale('es', 'GT'), // Guatemala
            Locale('es', 'HN'), // Honduras
            Locale('es', 'SV'), // El Salvador
            Locale('es', 'NI'), // Nicaragua
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.auth: (context) => const AuthScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.premium: (context) => const PremiumScreen(),
            '/settings': (context) => const SettingsScreen(),
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
      },
    );
  }
}
