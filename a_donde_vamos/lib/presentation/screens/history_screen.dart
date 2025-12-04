// lib/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📜 Historial')),
      body: const Center(
        child: Text(
          'Pantalla de Historial\n(Próximamente)',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
