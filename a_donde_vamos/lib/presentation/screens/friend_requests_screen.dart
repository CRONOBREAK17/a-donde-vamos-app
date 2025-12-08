// lib/presentation/screens/friend_requests_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import '../../data/services/friendship_service.dart';
import '../widgets/neon_alert_dialog.dart';
import 'user_profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  final _friendshipService = FriendshipService();
  late TabController _tabController;

  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> _outgoingRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final incoming = await _friendshipService.getIncomingRequests();
    final outgoing = await _friendshipService.getOutgoingRequests();

    setState(() {
      _incomingRequests = incoming;
      _outgoingRequests = outgoing;
      _isLoading = false;
    });
  }

  Future<void> _acceptRequest(String requestId) async {
    final result = await _friendshipService.acceptFriendRequest(requestId);

    if (!mounted) return;

    if (result['success']) {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.check_circle,
        title: '¡Genial!',
        message: 'Ahora son amigos',
      );
      _loadRequests();
    } else {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        message: result['message'],
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final result = await _friendshipService.rejectFriendRequest(requestId);

    if (!mounted) return;

    if (result['success']) {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.check_circle,
        title: 'Listo',
        message: 'Solicitud rechazada',
      );
      _loadRequests();
    } else {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        message: result['message'],
      );
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    final result = await _friendshipService.cancelFriendRequest(requestId);

    if (!mounted) return;

    if (result['success']) {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.check_circle,
        title: 'Listo',
        message: 'Solicitud cancelada',
      );
      _loadRequests();
    } else {
      NeonAlertDialog.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        message: result['message'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '📩 Solicitudes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Recibidas'),
                  if (_incomingRequests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_incomingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enviadas'),
                  if (_outgoingRequests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_outgoingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildIncomingRequests(), _buildOutgoingRequests()],
            ),
    );
  }

  Widget _buildIncomingRequests() {
    if (_incomingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No tienes solicitudes',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _incomingRequests.length,
        itemBuilder: (context, index) {
          final request = _incomingRequests[index];
          final sender = request['sender'] as Map<String, dynamic>;
          return _buildIncomingRequestCard(request, sender);
        },
      ),
    );
  }

  Widget _buildOutgoingRequests() {
    if (_outgoingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No has enviado solicitudes',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _outgoingRequests.length,
        itemBuilder: (context, index) {
          final request = _outgoingRequests[index];
          final receiver = request['receiver'] as Map<String, dynamic>;
          return _buildOutgoingRequestCard(request, receiver);
        },
      ),
    );
  }

  Widget _buildIncomingRequestCard(
    Map<String, dynamic> request,
    Map<String, dynamic> sender,
  ) {
    final username = sender['username'] as String? ?? 'Usuario';
    final profilePic = sender['profile_picture'] as String?;
    final activityPoints = sender['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);
    final requestId = request['id'] as String;

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(userId: sender['id']),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: rankInfo.color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: rankInfo.color.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
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
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rankInfo.title,
                    style: TextStyle(color: rankInfo.color, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activityPoints pts',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Botones
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(requestId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Aceptar'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _rejectRequest(requestId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Rechazar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingRequestCard(
    Map<String, dynamic> request,
    Map<String, dynamic> receiver,
  ) {
    final username = receiver['username'] as String? ?? 'Usuario';
    final profilePic = receiver['profile_picture'] as String?;
    final activityPoints = receiver['activity_points'] as int? ?? 0;
    final rankInfo = RankUtils.getRankInfo(activityPoints);
    final requestId = request['id'] as String;

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(userId: receiver['id']),
                  ),
                );
              },
              child: Container(
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
            ),
            const SizedBox(width: 15),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildPremiumBadge(
                        receiver['is_premium'] as bool? ?? false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rankInfo.title,
                    style: TextStyle(color: rankInfo.color, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pendiente',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Botón cancelar
            OutlinedButton(
              onPressed: () => _cancelRequest(requestId),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.textMuted),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge(bool isPremium) {
    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
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
            Icon(Icons.star, size: 9, color: Colors.black),
            SizedBox(width: 3),
            Text(
              'PREMIUM',
              style: TextStyle(
                color: Colors.black,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        child: const Text(
          'GRATUITO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }
}
