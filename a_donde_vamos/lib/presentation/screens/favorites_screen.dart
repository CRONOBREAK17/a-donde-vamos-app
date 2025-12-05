// lib/presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/neon_alert_dialog.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  List<Map<String, dynamic>> _favoriteLists = [];
  Map<String, dynamic>? _selectedList;
  List<Map<String, dynamic>> _placesInSelectedList = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteLists();
  }

  Future<void> _loadFavoriteLists() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('favorite_lists')
          .select('*')
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      setState(() {
        _favoriteLists = List<Map<String, dynamic>>.from(response);
        // Seleccionar primera lista por defecto
        if (_favoriteLists.isNotEmpty && _selectedList == null) {
          _selectedList = _favoriteLists.first;
          _loadPlacesInList(_selectedList!['id']);
        }
      });
    } catch (e) {
      debugPrint('Error loading favorite lists: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPlacesInList(String listId) async {
    try {
      final response = await _supabase
          .from('favorite_places')
          .select('*')
          .eq('list_id', listId)
          .order('created_at', ascending: false);

      setState(() {
        _placesInSelectedList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading places: $e');
    }
  }

  Future<void> _createNewList() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Nueva Lista',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nombre de la lista',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('favorite_lists').insert({
        'user_id': user.id,
        'name': result,
        'is_default': false,
      });

      _loadFavoriteLists();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const NeonAlertDialog(
            title: '✅ ¡Lista creada!',
            message: 'Tu nueva lista de favoritos ha sido creada',
            isSuccess: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => NeonAlertDialog(
            title: '❌ Error',
            message: 'No se pudo crear la lista: $e',
            iconColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePlace(String placeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Eliminar',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Eliminar este lugar de favoritos?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _supabase.from('favorite_places').delete().eq('id', placeId);
      _loadPlacesInList(_selectedList!['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lugar eliminado de favoritos')),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => NeonAlertDialog(
            title: '❌ Error',
            message: 'No se pudo eliminar: $e',
            iconColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openMapsUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    // Parsear place_data si es necesario
    String mapsUrl = url;
    if (url.contains('place_id')) {
      // Es un Google Place ID, construir URL
      mapsUrl = 'https://www.google.com/maps/place/?q=place_id:$url';
    }

    final uri = Uri.parse(mapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⭐ Favoritos'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewList,
            tooltip: 'Nueva Lista',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteLists.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildListSelector(),
                Expanded(child: _buildPlacesList()),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 20),
            const Text(
              'No tienes listas de favoritos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Crea tu primera lista para guardar lugares que te gusten',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _createNewList,
              icon: const Icon(Icons.add),
              label: const Text('Crear Lista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _favoriteLists.length,
        itemBuilder: (context, index) {
          final list = _favoriteLists[index];
          final isSelected = _selectedList?['id'] == list['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                '${list['name']} ${list['is_default'] == true ? "📌" : ""}',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedList = list);
                  _loadPlacesInList(list['id']);
                }
              },
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[700]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlacesList() {
    if (_placesInSelectedList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 60, color: Colors.grey[700]),
              const SizedBox(height: 15),
              Text(
                'La lista "${_selectedList?['name'] ?? ''}" está vacía',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Añade lugares favoritos desde la pantalla de exploración',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPlacesInList(_selectedList!['id']),
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _placesInSelectedList.length,
        itemBuilder: (context, index) {
          final place = _placesInSelectedList[index];

          return Card(
            color: AppColors.cardBackground,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.pink.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite, color: Colors.pink, size: 30),
              ),
              title: Text(
                place['place_name'] ?? 'Sin nombre',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                place['place_address'] ?? '',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.map, color: AppColors.primary),
                    onPressed: () => _openMapsUrl(place['place_data']),
                    tooltip: 'Ver en Maps',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _deletePlace(place['id']),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
