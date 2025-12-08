// lib/presentation/screens/premium_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_utils.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⭐ Premium'),
        backgroundColor: AppColors.cardBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header con gradiente dorado
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.star, size: 80, color: Colors.black),
                  SizedBox(height: 15),
                  Text(
                    '¡Hazte Premium!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Disfruta de una experiencia sin límites',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Beneficios
            const Text(
              '✨ Beneficios Exclusivos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            _buildBenefitCard(
              icon: Icons.block,
              title: 'Sin Anuncios',
              description: 'Navega sin interrupciones ni publicidad',
              color: const Color(0xFF00D9FF),
            ),

            _buildBenefitCard(
              icon: Icons.search,
              title: 'Búsquedas Ilimitadas',
              description: 'Descubre tantos lugares como quieras',
              color: const Color(0xFFFF1493),
            ),

            _buildBenefitCard(
              icon: Icons.filter_alt,
              title: 'Filtros Avanzados',
              description: 'Personaliza tus búsquedas con más opciones',
              color: const Color(0xFF9370DB),
            ),

            _buildBenefitCard(
              icon: Icons.star_rate,
              title: 'Insignia Exclusiva',
              description: 'Destaca en el ranking con tu badge premium',
              color: const Color(0xFFFFD700),
            ),

            _buildBenefitCard(
              icon: Icons.priority_high,
              title: 'Prioridad en Soporte',
              description: 'Atención preferencial para tus consultas',
              color: const Color(0xFF32CD32),
            ),

            _buildBenefitCard(
              icon: Icons.new_releases,
              title: 'Funciones Futuras',
              description: 'Acceso anticipado a nuevas características',
              color: const Color(0xFFFF6B35),
            ),

            const SizedBox(height: 30),

            // Precio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Solo',
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    CurrencyUtils.getPriceText(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const Text(
                    'al mes',
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '💎 Cancela cuando quieras',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botón de suscripción
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar Google Play Billing
                  _showComingSoonDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  '⭐ Suscribirme Ahora',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tal vez después',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.construction, color: Color(0xFFFFD700)),
            SizedBox(width: 10),
            Text(
              'Próximamente',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: const Text(
          'El sistema de pagos estará disponible muy pronto. Por ahora estamos usando IDs de prueba de AdMob.\n\nPasos siguientes:\n1. Configura tu cuenta de AdMob\n2. Obtén tus Ad Unit IDs\n3. Configura Google Play Billing',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
