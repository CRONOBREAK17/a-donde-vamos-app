// lib/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/ad_banner_widget.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  bool _isLoading = false;
  bool _isPremium = false;
  List<Map<String, dynamic>> _visitedPlaces = [];
  List<Map<String, dynamic>> _pendingPlaces = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
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
        if (mounted) {
          setState(() {
            _isPremium = response['is_premium'] ?? false;
          });
        }
      }
    } catch (e) {
      // Ignorar errores
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Cargar lugares visitados
      final visitedResponse = await _supabase
          .from('user_visited_places')
          .select(
            'location_name, location_address, visited_at, google_maps_url',
          )
          .eq('user_id', user.id)
          .order('visited_at', ascending: false);

      // Cargar lugares pendientes (sugerencias)
      final pendingResponse = await _supabase
          .from('user_pending_locations')
          .select(
            'location_name, location_address, google_maps_url, recommended_at',
          )
          .eq('user_id', user.id)
          .order('recommended_at', ascending: false)
          .limit(50);

      setState(() {
        _visitedPlaces = List<Map<String, dynamic>>.from(visitedResponse);
        _pendingPlaces = List<Map<String, dynamic>>.from(pendingResponse);
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMapsUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📜 Historial'),
        backgroundColor: AppColors.cardBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: '✅ Visitados (${_visitedPlaces.length})'),
            Tab(text: '🔔 Pendientes (${_pendingPlaces.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildVisitedTab(), _buildPendingTab()],
            ),
    );
  }

  Widget _buildVisitedTab() {
    if (_visitedPlaces.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '¡Aún no has visitado ningún lugar!\n\nMarca lugares como visitados desde la pantalla de exploración 🗺️',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount:
            _visitedPlaces.length + (_isPremium ? 0 : 1), // +1 para el ad
        itemBuilder: (context, index) {
          // Mostrar banner ad al final si no es premium
          if (index == _visitedPlaces.length && !_isPremium) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AdBannerWidget(),
            );
          }

          final place = _visitedPlaces[index];
          final visitedAt = DateTime.parse(place['visited_at']);
          final formattedDate = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(visitedAt);

          return Card(
            color: AppColors.cardBackground,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              title: Text(
                place['location_name'] ?? 'Sin nombre',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    place['location_address'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🕐 Visitado: $formattedDate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.map, color: AppColors.primary),
                onPressed: () => _openMapsUrl(place['google_maps_url']),
                tooltip: 'Ver en Maps',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingPlaces.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No tienes sugerencias pendientes\n\nCuando explores lugares, aparecerán aquí como recordatorio 📍',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _pendingPlaces.length,
        itemBuilder: (context, index) {
          final place = _pendingPlaces[index];
          final recommendedAt = DateTime.parse(place['recommended_at']);
          final formattedDate = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(recommendedAt);

          return Card(
            color: AppColors.cardBackground,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.amber,
                  size: 30,
                ),
              ),
              title: Text(
                place['location_name'] ?? 'Sin nombre',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    place['location_address'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 Sugerido: $formattedDate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.map, color: Colors.amber),
                onPressed: () => _openMapsUrl(place['google_maps_url']),
                tooltip: 'Ver en Maps',
              ),
            ),
          );
        },
      ),
    );
  }
}
