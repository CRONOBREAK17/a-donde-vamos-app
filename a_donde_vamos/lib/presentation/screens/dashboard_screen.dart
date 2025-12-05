// lib/presentation/screens/dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/location_service.dart';
import '../../data/services/places_service.dart';
import '../../data/services/user_places_service.dart';
import '../../data/services/ad_service.dart';
import '../../data/models/location_model.dart';
import '../widgets/neon_alert_dialog.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/achievement_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();
  final UserPlacesService _userPlacesService = UserPlacesService();
  final AdService _adService = AdService();
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _showFilters = false;
  String _selectedType = 'restaurant';
  double _searchRadius = 3.0; // en km
  String _selectedTimeOfDay = 'anytime';
  String _selectedCompany = 'anyone';
  bool _isPremium = false;

  Position? _currentPosition;
  LocationModel? _persistentPlace; // Lugar que permanece visible
  double? _persistentDistance; // Distancia del lugar persistente
  String? _locationError;

  @override
  void initState() {
    super.initState();
    // Obtener ubicación en segundo plano sin bloquear el UI
    Future.microtask(() => _getCurrentLocation());
    // Cargar sitio persistente si existe
    _loadPersistentPlace();
    // Verificar estado premium y cargar ads si es necesario
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('users')
            .select('is_premium')
            .eq('id', user.id)
            .single();

        setState(() {
          _isPremium = response['is_premium'] ?? false;
        });
      }

      // Si no es premium, cargar anuncios
      if (!_isPremium) {
        _adService.createBannerAd();
        _adService.createInterstitialAd();
      }
    } catch (e) {
      debugPrint('Error verificando premium: $e');
      // Por defecto cargar ads si hay error
      _adService.createBannerAd();
      _adService.createInterstitialAd();
    }
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
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

    // Mostrar interstitial ad cada 3 búsquedas (solo si no es premium)
    if (!_isPremium) {
      _adService.showInterstitialIfReady();
    }

    setState(() {
      _isLoading = true;
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

        // Guardar sitio de forma persistente (en memoria y SharedPreferences)
        await _savePersistentPlace(place, distance);

        setState(() {
          _persistentPlace = place;
          _persistentDistance = distance;
          _isLoading = false;
        });
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

  Future<void> _markPlaceAsVisited() async {
    if (_persistentPlace == null) return;

    print('📍 Marcando lugar como visitado...');
    final result = await _userPlacesService.markAsVisited(_persistentPlace!);
    print('📦 Resultado: $result');

    if (result['success'] == true) {
      // Borrar del almacenamiento persistente
      await _clearPersistentPlace();

      setState(() {
        _persistentPlace = null;
        _persistentDistance = null;
      });

      if (mounted) {
        NeonAlertDialog.show(
          context: context,
          icon: Icons.check_circle,
          title: '¡Lugar visitado!',
          message: 'Se agregó a tu historial correctamente',
          isSuccess: true,
        );

        // Mostrar logros si se desbloquearon
        print('🔍 Verificando badges: ${result['badges']}');
        if (result['badges'] != null &&
            result['badges'] is List &&
            (result['badges'] as List).isNotEmpty) {
          final badges = result['badges'] as List;
          print('🎊 Mostrando ${badges.length} logros secuencialmente...');

          // Mostrar cada insignia con delay entre ellas
          for (int i = 0; i < badges.length; i++) {
            final badge = badges[i] as Map<String, dynamic>;
            await AchievementDialog.show(
              context: context,
              badgeName: badge['name'] ?? 'Nuevo logro',
              badgeDescription: badge['description'] ?? '',
              badgeIcon: badge['icon_url'],
              delay: Duration(
                seconds: 3 + (i * 6),
              ), // 3s para primero, +6s para cada siguiente
            );
          }
        } else {
          print('❌ No se desbloqueó ninguna insignia');
        }
      }
    } else {
      if (mounted) {
        NeonAlertDialog.show(
          context: context,
          icon: Icons.error_outline,
          title: 'Error',
          message: 'No se pudo marcar como visitado',
        );
      }
    }
  }

  // Guardar lugar persistente en SharedPreferences
  Future<void> _savePersistentPlace(
    LocationModel place,
    double distance,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final placeJson = place.toJson();
      await prefs.setString('persistent_place', jsonEncode(placeJson));
      await prefs.setDouble('persistent_distance', distance);
    } catch (e) {
      debugPrint('Error guardando lugar persistente: $e');
    }
  }

  // Cargar lugar persistente de SharedPreferences
  Future<void> _loadPersistentPlace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final placeString = prefs.getString('persistent_place');
      final distance = prefs.getDouble('persistent_distance');

      if (placeString != null && distance != null) {
        final placeJson = jsonDecode(placeString) as Map<String, dynamic>;
        final place = LocationModel.fromJson(placeJson);

        if (mounted) {
          setState(() {
            _persistentPlace = place;
            _persistentDistance = distance;
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando lugar persistente: $e');
    }
  }

  // Borrar lugar persistente de SharedPreferences
  Future<void> _clearPersistentPlace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('persistent_place');
      await prefs.remove('persistent_distance');
    } catch (e) {
      debugPrint('Error borrando lugar persistente: $e');
    }
  }

  Future<void> _openInMaps() async {
    if (_persistentPlace == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_persistentPlace!.latitude},${_persistentPlace!.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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

              // Resultado (panel persistente o placeholder)
              _persistentPlace != null
                  ? _buildPersistentPlacePanel()
                  : _buildResultPlaceholder(),

              const SizedBox(height: 20),

              // Banner Ad (solo si no es premium)
              if (!_isPremium) const AdBannerWidget(),
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

  Widget _buildPersistentPlacePanel() {
    final place = _persistentPlace!;
    final distanceText = _locationService.formatDistance(_persistentDistance!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del panel
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dirección
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distancia, Rating, Precio
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.straighten,
                label: distanceText,
                color: AppColors.primary,
              ),
              if (place.rating != null)
                _buildInfoChip(
                  icon: Icons.star,
                  label: place.rating!.toStringAsFixed(1),
                  color: Colors.amber,
                ),
              if (place.priceLevel != null)
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: place.priceDisplay,
                  color: Colors.green,
                ),
            ],
          ),

          // Teléfono (si existe)
          if (place.phoneNumber != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  place.phoneNumber!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openInMaps,
                  icon: const Icon(Icons.map),
                  label: const Text('Abrir Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/place-detail',
                      arguments: {
                        'place': place,
                        'distance': _persistentDistance,
                      },
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver detalles'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markPlaceAsVisited,
              icon: const Icon(Icons.check_circle),
              label: const Text('Ya visité este lugar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
