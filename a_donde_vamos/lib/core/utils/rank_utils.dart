// lib/core/utils/rank_utils.dart
import 'package:flutter/material.dart';

class RankInfo {
  final String title;
  final Color color;
  final String className;
  final int minPoints;

  const RankInfo({
    required this.title,
    required this.color,
    required this.className,
    required this.minPoints,
  });
}

class RankUtils {
  // Colores de rangos (exactos de tu web)
  static const Color godColor = Color(0xFFFF00FF); // #ff00ff - Magenta
  static const Color masterColor = Color(0xFF00FFFF); // #00ffff - Cyan
  static const Color eliteColor = Color(0xFFFFD700); // #ffd700 - Gold
  static const Color veteranColor = Color(0xFFC0C0C0); // #c0c0c0 - Silver
  static const Color expertColor = Color(0xFFCD7F32); // #cd7f32 - Bronze
  static const Color proColor = Color(0xFF9370DB); // #9370db - Purple
  static const Color amateurColor = Color(0xFF32CD32); // #32cd32 - Green
  static const Color noviceColor = Color(0xFF555555); // #555555 - Gray

  // Obtener información de rango basado en puntos
  static RankInfo getRankInfo(int points) {
    if (points >= 1000) {
      return const RankInfo(
        title: 'LEYENDA CÓSMICA 🌌',
        color: godColor,
        className: 'rank-god',
        minPoints: 1000,
      );
    }
    if (points >= 700) {
      return const RankInfo(
        title: 'Viajero Maestro 💎',
        color: masterColor,
        className: 'rank-master',
        minPoints: 700,
      );
    }
    if (points >= 500) {
      return const RankInfo(
        title: 'Explorador Élite 🥇',
        color: eliteColor,
        className: 'rank-elite',
        minPoints: 500,
      );
    }
    if (points >= 300) {
      return const RankInfo(
        title: 'Aventurero Veterano 🥈',
        color: veteranColor,
        className: 'rank-veteran',
        minPoints: 300,
      );
    }
    if (points >= 200) {
      return const RankInfo(
        title: 'Caminante Experto 🥉',
        color: expertColor,
        className: 'rank-expert',
        minPoints: 200,
      );
    }
    if (points >= 100) {
      return const RankInfo(
        title: 'Turista Curioso 📷',
        color: proColor,
        className: 'rank-pro',
        minPoints: 100,
      );
    }
    if (points >= 50) {
      return const RankInfo(
        title: 'Visitante Amateur 🎒',
        color: amateurColor,
        className: 'rank-amateur',
        minPoints: 50,
      );
    }
    return const RankInfo(
      title: 'Novato',
      color: noviceColor,
      className: 'rank-novice',
      minPoints: 0,
    );
  }

  // Obtener siguiente rango
  static RankInfo? getNextRank(int currentPoints) {
    if (currentPoints >= 1000) return null; // Ya es máximo rango

    if (currentPoints >= 700) return getRankInfo(1000);
    if (currentPoints >= 500) return getRankInfo(700);
    if (currentPoints >= 300) return getRankInfo(500);
    if (currentPoints >= 200) return getRankInfo(300);
    if (currentPoints >= 100) return getRankInfo(200);
    if (currentPoints >= 50) return getRankInfo(100);
    return getRankInfo(50);
  }

  // Calcular progreso hacia siguiente rango (0.0 a 1.0)
  static double getProgressToNextRank(int points) {
    final currentRank = getRankInfo(points);
    final nextRank = getNextRank(points);

    if (nextRank == null) return 1.0; // Máximo rango alcanzado

    final pointsInCurrentRank = points - currentRank.minPoints;
    final pointsNeededForNext = nextRank.minPoints - currentRank.minPoints;

    return (pointsInCurrentRank / pointsNeededForNext).clamp(0.0, 1.0);
  }
}
