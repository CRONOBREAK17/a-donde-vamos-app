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
      child: Row(
        children: [
          // Botón de navegación
          Expanded(
            flex: 2,
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
                onPressed: _openNavigation,
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text(
                  '¡Vamos!',
                  style: TextStyle(
                    fontSize: 18,
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

          const SizedBox(width: 12),

          // Botón de llamar
          if (widget.place.phoneNumber != null)
            _buildCircularButton(icon: Icons.phone, onPressed: _makePhoneCall),

          const SizedBox(width: 12),

          // Botón de compartir
          _buildCircularButton(icon: Icons.share, onPressed: _sharePlace),
        ],
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
  Future<void> _openNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.place.latitude},${widget.place.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la navegación')),
        );
      }
    }
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
