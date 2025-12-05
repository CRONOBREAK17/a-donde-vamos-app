// lib/presentation/screens/friends_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import 'user_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  List<Map<String, dynamic>> _friends = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Cargar amigos (user_friends con JOIN a users)
      final response = await _supabase
          .from('user_friends')
          .select(
            'friend:users!user_friends_friend_id_fkey(id, username, profile_picture, activity_points)',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _friends = List<Map<String, dynamic>>.from(
          response.map((item) => item['friend'] as Map<String, dynamic>),
        );
      });
    } catch (e) {
      debugPrint('Error loading friends: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _loadFriends();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('users')
          .select('id, username, profile_picture, activity_points')
          .ilike('username', '%$query%')
          .limit(20);

      setState(() {
        _friends = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para agregar amigos - se puede usar desde un diálogo de búsqueda mejorado
  // ignore: unused_element
  Future<void> _addFriend(String friendId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_friends').insert({
        'user_id': user.id,
        'friend_id': friendId,
      });

      _loadFriends();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Amigo agregado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Buscar amigos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final username = friend['username'] as String? ?? 'Usuario';
    final profilePic = friend['profile_picture'] as String?;
    final activityPoints = friend['activity_points'] as int? ?? 0;

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
          child: profilePic == null
              ? Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          username,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '⭐ $activityPoints puntos',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
