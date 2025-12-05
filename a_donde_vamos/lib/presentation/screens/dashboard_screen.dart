// lib/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/location_service.dart';
import '../../data/services/places_service.dart';
import '../../data/models/location_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  bool _isLoading = false;
  bool _showFilters = false;
  String _selectedType = 'restaurant';
  double _searchRadius = 3.0; // en km
  String _selectedTimeOfDay = 'anytime';
  String _selectedCompany = 'anyone';

  Position? _currentPosition;
  LocationModel? _foundPlace;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    // Obtener ubicación en segundo plano sin bloquear el UI
    Future.microtask(() => _getCurrentLocation());
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _locationError = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      } else {
        setState(() {
          _locationError = 'No se pudo obtener la ubicación';
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _locationError = e.toString();
      });
    }
  }

  Future<void> _searchRandomPlace() async {
    if (_currentPosition == null) {
      _showErrorDialog('Error', 'Necesitamos tu ubicación para buscar lugares');
      return;
    }

    setState(() {
      _isLoading = true;
      _foundPlace = null;
    });

    try {
      final place = await _placesService.findRandomPlace(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        placeType: _selectedType,
        radiusInKm: _searchRadius,
      );

      if (place != null) {
        // Calcular distancia
        final distance = _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          place.latitude,
          place.longitude,
        );

        setState(() {
          _foundPlace = place;
          _isLoading = false;
        });

        _showPlaceDialog(place, distance);
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(
          'Sin resultados',
          'No encontramos lugares cerca. Intenta aumentar el radio de búsqueda.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error', 'Ocurrió un error al buscar: $e');
    }
  }

  void _showPlaceDialog(LocationModel place, double distanceInMeters) {
    final distanceText = _locationService.formatDistance(distanceInMeters);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🎉 ${place.name}',
          style: const TextStyle(color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 ${place.address}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '📏 Distancia: $distanceText',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (place.rating != null) ...[
              const SizedBox(height: 8),
              Text(
                '⭐ Rating: ${place.rating!.toStringAsFixed(1)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (place.priceLevel != null) ...[
              const SizedBox(height: 8),
              Text(
                '💰 Precio: ${place.priceDisplay}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/place-detail',
                arguments: {
                  'place': place,
                  'distance': distanceInMeters,
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Ver más'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: AppColors.secondary)),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_locationError != null) {
      statusText = _locationError!;
      statusColor = AppColors.secondary;
      statusIcon = Icons.location_off;
    } else if (_currentPosition != null) {
      statusText =
          'Ubicación obtenida (${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)})';
      statusColor = AppColors.primary;
      statusIcon = Icons.location_on;
    } else {
      statusText = 'Obteniendo ubicación...';
      statusColor = AppColors.primary;
      statusIcon = Icons.location_searching;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          _currentPosition == null && _locationError == null
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: statusColor,
                  ),
                )
              : Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación actual',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_locationError != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.secondary),
              onPressed: _getCurrentLocation,
              tooltip: 'Reintentar',
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
        onPressed: _isLoading ? null : _searchRandomPlace,
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
