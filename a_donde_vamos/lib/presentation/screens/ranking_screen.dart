// lib/presentation/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import 'user_profile_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _topUsers = [];
  List<Map<String, dynamic>> _topPlaces = [];
  int _limit = 50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _loadUsersRanking();
        } else {
          _loadPlacesRanking();
        }
      }
    });
    _loadUsersRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsersRanking() async {
    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('users')
          .select('id, username, profile_picture, activity_points, is_premium')
          .order('activity_points', ascending: false)
          .limit(_limit);

      setState(() {
        _topUsers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading users ranking: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPlacesRanking() async {
    setState(() => _isLoading = true);

    try {
      // Contar visitas por lugar usando la tabla user_places
      final response = await _supabase.rpc(
        'get_top_places',
        params: {'limit_count': _limit},
      );

      setState(() {
        _topPlaces = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading places ranking: $e');
      // Si falla el RPC, intentar con una query simple
      try {
        final fallbackResponse = await _supabase
            .from('user_places')
            .select(
              'place_name, place_address, place_latitude, place_longitude',
            )
            .eq('visited', true);

        // Agrupar manualmente por lugar
        final Map<String, Map<String, dynamic>> placesMap = {};
        for (var record in fallbackResponse) {
          final name = record['place_name'] as String;
          if (!placesMap.containsKey(name)) {
            placesMap[name] = {
              'place_name': name,
              'place_address': record['place_address'],
              'place_latitude': record['place_latitude'],
              'place_longitude': record['place_longitude'],
              'visit_count': 1,
            };
          } else {
            placesMap[name]!['visit_count'] =
                (placesMap[name]!['visit_count'] as int) + 1;
          }
        }

        // Convertir a lista y ordenar
        final placesList = placesMap.values.toList();
        placesList.sort(
          (a, b) =>
              (b['visit_count'] as int).compareTo(a['visit_count'] as int),
        );

        setState(() {
          _topPlaces = placesList.take(_limit).toList();
        });
      } catch (fallbackError) {
        debugPrint('Error in fallback query: $fallbackError');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏆 Ranking'),
        backgroundColor: AppColors.cardBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: '👥 Usuarios', icon: Icon(Icons.people)),
            Tab(text: '📍 Lugares', icon: Icon(Icons.place)),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _limit = value);
              if (_tabController.index == 0) {
                _loadUsersRanking();
              } else {
                _loadPlacesRanking();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 10, child: Text('Top 10')),
              const PopupMenuItem(value: 25, child: Text('Top 25')),
              const PopupMenuItem(value: 50, child: Text('Top 50')),
              const PopupMenuItem(value: 100, child: Text('Top 100')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de Usuarios
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _topUsers.isEmpty
              ? _buildEmptyState('No hay usuarios en el ranking')
              : RefreshIndicator(
                  onRefresh: _loadUsersRanking,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _topUsers.length,
                    itemBuilder: (context, index) {
                      final user = _topUsers[index];
                      return _buildUserRankCard(user, index + 1);
                    },
                  ),
                ),
          // Tab de Lugares
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _topPlaces.isEmpty
              ? _buildEmptyState('No hay lugares en el ranking')
              : RefreshIndicator(
                  onRefresh: _loadPlacesRanking,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _topPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _topPlaces[index];
                      return _buildPlaceRankCard(place, index + 1);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildUserRankCard(Map<String, dynamic> user, int position) {
    final username = user['username'] as String? ?? 'Usuario';
    final profilePic = user['profile_picture'] as String?;
    final activityPoints = user['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);

    // Colores especiales para top 3
    Color positionColor;
    IconData positionIcon;
    if (position == 1) {
      positionColor = const Color(0xFFFFD700); // Oro
      positionIcon = Icons.emoji_events;
    } else if (position == 2) {
      positionColor = const Color(0xFFC0C0C0); // Plata
      positionIcon = Icons.emoji_events;
    } else if (position == 3) {
      positionColor = const Color(0xFFCD7F32); // Bronce
      positionIcon = Icons.emoji_events;
    } else {
      positionColor = AppColors.textMuted;
      positionIcon = Icons.person;
    }

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: position <= 3
              ? positionColor.withOpacity(0.5)
              : rankInfo.color.withOpacity(0.3),
          width: position <= 3 ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: positionColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (position <= 3)
                    Icon(positionIcon, color: positionColor, size: 16),
                  Text(
                    '#$position',
                    style: TextStyle(
                      color: positionColor,
                      fontWeight: FontWeight.bold,
                      fontSize: position <= 3 ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Foto de perfil con borde de rango
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankInfo.color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rankInfo.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic)
                    : null,
                child: profilePic == null
                    ? Text(
                        username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: rankInfo.color,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            _buildPremiumBadge(user['is_premium'] as bool? ?? false),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rankInfo.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rankInfo.color.withOpacity(0.5)),
              ),
              child: Text(
                rankInfo.title,
                style: TextStyle(
                  color: rankInfo.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '⭐ $activityPoints puntos',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: user['id']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceRankCard(Map<String, dynamic> place, int position) {
    final placeName = place['place_name'] as String? ?? 'Lugar desconocido';
    final placeAddress = place['place_address'] as String? ?? 'Sin dirección';
    final visitCount = place['visit_count'] as int? ?? 0;

    // Colores especiales para top 3
    Color positionColor;
    IconData positionIcon;
    if (position == 1) {
      positionColor = const Color(0xFFFFD700); // Oro
      positionIcon = Icons.emoji_events;
    } else if (position == 2) {
      positionColor = const Color(0xFFC0C0C0); // Plata
      positionIcon = Icons.emoji_events;
    } else if (position == 3) {
      positionColor = const Color(0xFFCD7F32); // Bronce
      positionIcon = Icons.emoji_events;
    } else {
      positionColor = AppColors.textMuted;
      positionIcon = Icons.place;
    }

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: position <= 3
              ? positionColor.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.3),
          width: position <= 3 ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Posición
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: positionColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (position <= 3)
                    Icon(positionIcon, color: positionColor, size: 16),
                  Text(
                    '#$position',
                    style: TextStyle(
                      color: positionColor,
                      fontWeight: FontWeight.bold,
                      fontSize: position <= 3 ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ícono del lugar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ],
        ),
        title: Text(
          placeName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              placeAddress,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$visitCount ${visitCount == 1 ? 'visita' : 'visitas'}',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: () {
          // TODO: Abrir detalles del lugar o en Google Maps
          final lat = place['place_latitude'];
          final lng = place['place_longitude'];
          if (lat != null && lng != null) {
            // Mostrar diálogo con opción de abrir en Maps
            _showPlaceOptionsDialog(placeName, placeAddress, lat, lng);
          }
        },
      ),
    );
  }

  void _showPlaceOptionsDialog(
    String name,
    String address,
    double lat,
    double lng,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          address,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              // Abrir en Google Maps
              final url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.map),
            label: const Text('Abrir en Maps'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge(bool isPremium) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 10, color: Colors.black),
            SizedBox(width: 3),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        child: const Text(
          'GRATUITO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }
}
