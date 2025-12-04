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
  bool _showFilters = true;
  String _selectedType = 'restaurant';
  double _searchRadius = 3000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
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
    return ElevatedButton(
      onPressed: _isLoading ? null : () {
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
        backgroundColor: AppColors.primary,
      ),
      child: Text(
        _isLoading ? AppStrings.searching : AppStrings.searchButton,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFiltersToggle() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _showFilters = !_showFilters;
        });
      },
      icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
      label: const Text('Filtros'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _showFilters ? AppColors.secondary : AppColors.primary,
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de lugar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Restaurante', 'restaurant'),
                _buildFilterChip('Café', 'cafe'),
                _buildFilterChip('Bar', 'bar'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Radio de búsqueda',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Slider(
              value: _searchRadius,
              min: 1000,
              max: 5000,
              divisions: 4,
              label: '${(_searchRadius / 1000).toStringAsFixed(0)} km',
              onChanged: (value) {
                setState(() {
                  _searchRadius = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildResultPlaceholder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.place,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Presiona el botón para descubrir lugares increíbles cerca de ti',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
