// lib/presentation/screens/place_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/location_model.dart';
import '../../data/services/places_service.dart';

class PlaceDetailScreen extends StatefulWidget {
  final LocationModel place;
  final double distanceInMeters;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.distanceInMeters,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PlacesService _placesService = PlacesService();
  GoogleMapController? _mapController;
  bool _isFavorite = false;
  bool _isVisited = false;
  bool _isBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          _buildSliverAppBar(),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información principal
                _buildMainInfo(),

                // Mapa
                _buildMap(),

                // Botones de acción
                _buildActionButtons(),

                // Detalles adicionales
                _buildDetails(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.place.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: widget.place.photoReference != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _placesService.getPhotoUrl(widget.place.photoReference!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderImage(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.secondary : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            // TODO: Guardar en favoritos en Supabase
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isFavorite
                      ? '❤️ Agregado a favoritos'
                      : '💔 Eliminado de favoritos',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: Icon(Icons.restaurant, size: 100, color: AppColors.primary),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating y precio
          Row(
            children: [
              if (widget.place.rating != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        widget.place.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (widget.place.priceLevel != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.place.priceDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.place.formatDistance(widget.distanceInMeters),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dirección
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.place.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          // Estado (abierto/cerrado)
          if (widget.place.isOpen != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  widget.place.isOpen! ? Icons.check_circle : Icons.cancel,
                  color: widget.place.isOpen! ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.place.isOpen! ? 'Abierto ahora' : 'Cerrado',
                  style: TextStyle(
                    color: widget.place.isOpen! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.place.latitude, widget.place.longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(widget.place.id),
            position: LatLng(widget.place.latitude, widget.place.longitude),
            infoWindow: InfoWindow(title: widget.place.name),
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Fila principal: Navegación Waze
          Row(
            children: [
              // Botón de navegación Waze (principal)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _openWazeNavigation,
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      '🚗 ¡Vamos! (Waze)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Segunda fila: Botones secundarios
          Row(
            children: [
              // Botón Google Maps
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.map,
                  label: 'Google Maps',
                  onPressed: _openGoogleMaps,
                ),
              ),
              const SizedBox(width: 8),

              // Botón "Ya visité"
              Expanded(
                child: _buildSecondaryButton(
                  icon: _isVisited
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  label: 'Ya visité',
                  onPressed: _toggleVisited,
                  color: _isVisited ? Colors.green : null,
                ),
              ),
              const SizedBox(width: 8),

              // Botón de llamar (si hay teléfono)
              if (widget.place.phoneNumber != null)
                _buildCircularButton(
                  icon: Icons.phone,
                  onPressed: _makePhoneCall,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Tercera fila: Bloquear lugar
          OutlinedButton.icon(
            onPressed: _toggleBlockPlace,
            icon: Icon(_isBlocked ? Icons.block : Icons.visibility_off),
            label: Text(_isBlocked ? 'Lugar bloqueado' : 'No recomendar más'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _isBlocked
                  ? Colors.red
                  : AppColors.textSecondary,
              side: BorderSide(
                color: _isBlocked ? Colors.red : AppColors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color ?? AppColors.primary),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color ?? AppColors.primary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        iconSize: 28,
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Teléfono
          if (widget.place.phoneNumber != null)
            _buildDetailRow(
              icon: Icons.phone,
              label: 'Teléfono',
              value: widget.place.phoneNumber!,
            ),

          // Website
          if (widget.place.website != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.language,
              label: 'Sitio web',
              value: 'Ver sitio web',
              onTap: _openWebsite,
            ),
          ],

          // Tipos de lugar
          if (widget.place.types != null && widget.place.types!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.category,
              label: 'Categorías',
              value: widget.place.types!
                  .take(3)
                  .map((t) => t.replaceAll('_', ' '))
                  .join(', '),
            ),
          ],

          // Sección de opiniones
          const SizedBox(height: 24),
          const Text(
            'Opiniones de la comunidad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    // TODO: Obtener reviews de Supabase
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Aún no hay opiniones de este lugar',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Abrir modal para escribir opinión
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Escribe tu opinión'),
                ),
              );
            },
            icon: const Icon(Icons.rate_review, size: 18),
            label: const Text('Sé el primero en opinar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // Funciones de acción
  Future<void> _openWazeNavigation() async {
    // Intentar abrir Waze primero
    final wazeUrl = Uri.parse(
      'waze://?ll=${widget.place.latitude},${widget.place.longitude}&navigate=yes',
    );

    if (await canLaunchUrl(wazeUrl)) {
      await launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
    } else {
      // Si Waze no está instalado, abrir en browser para descargar
      final wazeWebUrl = Uri.parse(
        'https://www.waze.com/ul?ll=${widget.place.latitude},${widget.place.longitude}&navigate=yes',
      );

      if (await canLaunchUrl(wazeWebUrl)) {
        await launchUrl(wazeWebUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir Waze. ¿Está instalado?'),
            ),
          );
        }
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.place.latitude},${widget.place.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    }
  }

  void _toggleVisited() {
    setState(() {
      _isVisited = !_isVisited;
    });

    // TODO: Guardar en Supabase tabla visited_places
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVisited ? '✅ Marcado como visitado' : 'Desmarcado como visitado',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBlockPlace() {
    setState(() {
      _isBlocked = !_isBlocked;
    });

    // TODO: Guardar en Supabase tabla blocked_locations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBlocked
              ? '🚫 Este lugar no se recomendará más'
              : 'Lugar desbloqueado',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _isBlocked ? Colors.red : null,
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    if (widget.place.phoneNumber == null) return;

    final url = Uri.parse('tel:${widget.place.phoneNumber}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo realizar la llamada')),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    if (widget.place.website == null) return;

    final url = Uri.parse(widget.place.website!);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el sitio web')),
        );
      }
    }
  }

  Future<void> _sharePlace() async {
    // TODO: Implementar compartir con share_plus package
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Compartir: ${widget.place.name}')));
  }
}
