// lib/presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Favoritos')),
      body: const Center(
        child: Text(
          'Pantalla de Favoritos\n(Próximamente)',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
