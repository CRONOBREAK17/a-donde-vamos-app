// lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si hay sesión activa
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Usuario ya tiene sesión activa
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // No hay sesión, ir a login
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o ícono
              const Icon(Icons.explore, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
