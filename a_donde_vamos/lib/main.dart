import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/language_service.dart';
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

  // Inicializar servicio de idioma
  final languageService = LanguageService();
  await languageService.loadSavedLanguage();

  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;

  const MyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: languageService,
      child: Consumer<LanguageService>(
        builder: (context, langService, child) {
          return MaterialApp(
            title: '¿A Dónde Vamos?',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,

            // Configuración de localización
            locale: langService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'MX'),
              Locale('en', 'US'),
              Locale('es', 'ES'),
              Locale('es', 'AR'),
              Locale('es', 'CL'),
              Locale('es', 'CO'),
              Locale('es', 'PE'),
              Locale('es', 'VE'),
            ],

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
        },
      ),
    );
  }
}
