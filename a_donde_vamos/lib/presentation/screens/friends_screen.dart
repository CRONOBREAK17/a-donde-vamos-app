// lib/presentation/screens/friends_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import '../../data/services/friendship_service.dart';
import '../widgets/neon_alert_dialog.dart';
import 'user_profile_screen.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _friendshipService = FriendshipService();

  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _searchResults = [];
  int _pendingRequestsCount = 0;
  final _searchController = TextEditingController();

  // Mapa para guardar el estado de amistad de cada usuario buscado
  final Map<String, String> _friendshipStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadPendingCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    final friends = await _friendshipService.getFriends();

    setState(() {
      _friends = friends;
      _isLoading = false;
    });
  }

  Future<void> _loadPendingCount() async {
    final incoming = await _friendshipService.getIncomingRequests();
    setState(() {
      _pendingRequestsCount = incoming.length;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _friendshipStatuses.clear();
      });
      return;
    }

    setState(() => _isLoading = true);

    final results = await _friendshipService.searchUsers(query);

    // Verificar el estado de amistad para cada resultado
    _friendshipStatuses.clear();
    for (var user in results) {
      final status = await _friendshipService.checkFriendshipStatus(user['id']);
      _friendshipStatuses[user['id']] = status;
    }

    setState(() {
      _searchResults = results;
      _isSearching = true;
      _isLoading = false;
    });
  }

  Future<void> _sendFriendRequest(String userId) async {
    final result = await _friendshipService.sendFriendRequest(userId);

    if (!mounted) return;

    if (result['success']) {
      // Actualizar el estado local inmediatamente
      setState(() {
        _friendshipStatuses[userId] = 'request_sent';
      });

      NeonAlertDialog.show(
        context: context,
        icon: Icons.check_circle,
        title: '¡Listo!',
        message: result['message'],
      );
    } else {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Aviso',
        message: result['message'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('👥 Amigos'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          // Botón de solicitudes con badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.mail_outline),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsScreen(),
                    ),
                  );
                  _loadPendingCount();
                },
                tooltip: 'Solicitudes',
              ),
              if (_pendingRequestsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_pendingRequestsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Buscar usuarios',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(15),
              color: AppColors.cardBackground,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resultados: ${_searchResults.length}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchResults = [];
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cerrar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isSearching
                ? _buildSearchResults()
                : _friends.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadFriends,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _friends.length,
                      itemBuilder: (context, index) {
                        final friend = _friends[index];
                        return _buildFriendCard(friend);
                      },
                    ),
                  ),
          ),
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
            Icon(Icons.person_add_alt_1, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 20),
            const Text(
              'No tienes amigos agregados',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Busca usuarios y agrégalos como amigos',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _showSearchDialog,
              icon: const Icon(Icons.search),
              label: const Text('Buscar amigos'),
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

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No se encontraron usuarios',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildSearchResultCard(user);
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> user) {
    final username = user['username'] as String? ?? 'Usuario';
    final profilePic = user['profile_picture'] as String?;
    final activityPoints = user['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);
    final userId = user['id'] as String;
    final friendshipStatus = _friendshipStatuses[userId] ?? 'none';

    // Determinar el botón según el estado
    Widget trailingButton;
    if (friendshipStatus == 'friends') {
      trailingButton = ElevatedButton.icon(
        onPressed: null, // Deshabilitado
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Amigos'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textMuted.withOpacity(0.3),
          foregroundColor: AppColors.textMuted,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (friendshipStatus == 'request_sent') {
      trailingButton = ElevatedButton.icon(
        onPressed: null, // Deshabilitado
        icon: const Icon(Icons.schedule, size: 18),
        label: const Text('Pendiente'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textMuted.withOpacity(0.3),
          foregroundColor: AppColors.textMuted,
          disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (friendshipStatus == 'request_received') {
      trailingButton = ElevatedButton.icon(
        onPressed: null, // Deshabilitado - deben ir a solicitudes para aceptar
        icon: const Icon(Icons.mail, size: 18),
        label: const Text('Solicitud'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.3),
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          disabledForegroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      // Estado 'none' - puede agregar
      trailingButton = ElevatedButton.icon(
        onPressed: () => _sendFriendRequest(userId),
        icon: const Icon(Icons.person_add, size: 18),
        label: const Text('Agregar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankInfo.color, width: 2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            backgroundImage: profilePic != null
                ? NetworkImage(profilePic)
                : null,
            child: profilePic == null
                ? Text(
                    username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rankInfo.color,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rankInfo.title,
              style: TextStyle(color: rankInfo.color, fontSize: 12),
            ),
            Text(
              '$activityPoints pts',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        trailing: trailingButton,
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

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final username = friend['username'] as String? ?? 'Usuario';
    final profilePic = friend['profile_picture'] as String?;
    final activityPoints = friend['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);

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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rankInfo.color, width: 2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            backgroundImage: profilePic != null
                ? NetworkImage(profilePic)
                : null,
            child: profilePic == null
                ? Text(
                    username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: rankInfo.color,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rankInfo.title,
              style: TextStyle(color: rankInfo.color, fontSize: 12),
            ),
            Text(
              '$activityPoints pts',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
              builder: (context) => UserProfileScreen(userId: friend['id']),
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Buscar usuarios',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nombre de usuario...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchUsers(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchUsers(_searchController.text);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
