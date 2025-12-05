// lib/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  bool _showFilters = false;
  String _selectedType = 'restaurant';
  double _searchRadius = 3.0; // en km
  String _selectedTimeOfDay = 'anytime';
  String _selectedCompany = 'anyone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ).createShader(bounds),
              child: const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('🤔', style: TextStyle(fontSize: 22)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Mostrar notificaciones
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado de ubicación
              _buildLocationStatus(),
              const SizedBox(height: 24),

              // Botón principal
              _buildMainButton(),
              const SizedBox(height: 16),

              // Botón de filtros
              _buildFiltersToggle(),

              // Filtros (si están visibles)
              if (_showFilters) ...[
                const SizedBox(height: 24),
                _buildFilters(),
              ],

              const SizedBox(height: 24),

              // Resultado (placeholder)
              _buildResultPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación actual',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Obteniendo ubicación...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                // TODO: Buscar lugares aleatorios
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLoading ? AppStrings.searching : AppStrings.searchButton,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Text('🚀', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _showFilters = !_showFilters;
          });
        },
        icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
        label: Text(_showFilters ? 'Ocultar Filtros' : 'Filtros'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de lugar
          _buildFilterSection(
            '1. Tipo de Lugar:',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Restaurante', 'restaurant', Icons.restaurant),
                _buildFilterChip('Café', 'cafe', Icons.local_cafe),
                _buildFilterChip('Bar', 'bar', Icons.local_bar),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Radio de búsqueda
          _buildFilterSection(
            '2. Radio de Búsqueda:',
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRadiusChip('1km', 1.0),
                    _buildRadiusChip('3km', 3.0),
                    _buildRadiusChip('5km', 5.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Momento del día
          _buildFilterSection(
            '3. Momento del día:',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  'Cualquier Hora',
                  'anytime',
                  Icons.access_time,
                  filterType: 'time',
                ),
                _buildFilterChip(
                  'Desayuno',
                  'breakfast',
                  Icons.free_breakfast,
                  filterType: 'time',
                ),
                _buildFilterChip(
                  'Almuerzo',
                  'lunch',
                  Icons.lunch_dining,
                  filterType: 'time',
                ),
                _buildFilterChip(
                  'Cena',
                  'dinner',
                  Icons.dinner_dining,
                  filterType: 'time',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Compañía
          _buildFilterSection(
            '4. Compañía:',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  'Cualquiera',
                  'anyone',
                  Icons.people,
                  filterType: 'company',
                  emoji: '✨',
                ),
                _buildFilterChip(
                  'Citas',
                  'date',
                  Icons.favorite,
                  filterType: 'company',
                  emoji: '💕',
                ),
                _buildFilterChip(
                  'Amigos',
                  'friends',
                  Icons.group,
                  filterType: 'company',
                  emoji: '👥',
                ),
                _buildFilterChip(
                  'Familia',
                  'family',
                  Icons.family_restroom,
                  filterType: 'company',
                  emoji: '👨‍👩‍👧‍👦',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    IconData? icon, {
    String filterType = 'type',
    String? emoji,
  }) {
    bool isSelected;
    switch (filterType) {
      case 'time':
        isSelected = _selectedTimeOfDay == value;
        break;
      case 'company':
        isSelected = _selectedCompany == value;
        break;
      default:
        isSelected = _selectedType == value;
    }

    return InkWell(
      onTap: () {
        setState(() {
          switch (filterType) {
            case 'time':
              _selectedTimeOfDay = value;
              break;
            case 'company':
              _selectedCompany = value;
              break;
            default:
              _selectedType = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (emoji != null) ...[
              const SizedBox(width: 6),
              Text(emoji, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusChip(String label, double km) {
    final isSelected = _searchRadius == km;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _searchRadius = km;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.place, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Presiona el botón para descubrir lugares increíbles cerca de ti',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
