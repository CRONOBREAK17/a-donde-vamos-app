// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Colores principales (basados en tu web)
  static const Color primary = Color(0xFF00BFFF); // Azul neón
  static const Color secondary = Color(0xFFFF1493); // Rosa neón
  static const Color background = Color(0xFF0A0E27); // Fondo oscuro
  static const Color cardBackground = Color(0xFF1A1F3A); // Fondo de cards
  
  // Colores de acento
  static const Color success = Color(0xFF00FF7F);
  static const Color warning = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF007F);
  static const Color info = Color(0xFF00BFFF);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textMuted = Color(0xFF888888);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00BFFF), Color(0xFF0090CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF007F), Color(0xFFCC0066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
