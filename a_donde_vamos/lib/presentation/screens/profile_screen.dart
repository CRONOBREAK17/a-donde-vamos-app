// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/rank_utils.dart';
import '../widgets/rank_profile_picture.dart';
import '../widgets/neon_alert_dialog.dart';
import '../widgets/ad_banner_widget.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingImage = false;
  bool _isPremium = false;
  String? _userId;
  String? _email;
  String _username = '';
  String _description = '';
  String? _profilePicture;
  int _activityPoints = 0;
  List<Map<String, dynamic>> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      _userId = user.id;
      _email = user.email;

      // Obtener datos del perfil
      final response = await _supabase
          .from('users')
          .select(
            'username, description, activity_points, profile_picture, is_premium',
          )
          .eq('id', user.id)
          .single();

      // Obtener insignias
      final badgesResponse = await _supabase
          .from('user_badges')
          .select('''
            awarded_at,
            badge:badges_list(name, description, criteria, icon_url)
          ''')
          .eq('user_id', user.id)
          .order('awarded_at', ascending: false);

      setState(() {
        _username = response['username'] as String? ?? '';
        _description = response['description'] as String? ?? '';
        _activityPoints = response['activity_points'] as int? ?? 0;
        _profilePicture = response['profile_picture'] as String?;
        _isPremium = response['is_premium'] as bool? ?? false;
        _badges = List<Map<String, dynamic>>.from(badgesResponse);
        _descriptionController.text = _description;
      });
    } catch (e) {
      if (mounted) {
        _showError('Error al cargar perfil: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateDescription() async {
    if (_descriptionController.text.trim() == _description) return;

    setState(() => _isLoading = true);

    try {
      await _supabase
          .from('users')
          .update({'description': _descriptionController.text.trim()})
          .eq('id', _userId!);

      setState(() => _description = _descriptionController.text.trim());

      if (mounted) {
        _showSuccess('¡Biografía actualizada!');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al actualizar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoadingImage = true);

      // Subir a Supabase Storage
      final fileExt = image.path.split('.').last;
      final fileName =
          '$_userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            File(image.path),
            fileOptions: const FileOptions(upsert: true),
          );

      // Obtener URL pública
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Actualizar en la base de datos
      await _supabase
          .from('users')
          .update({'profile_picture': publicUrl})
          .eq('id', _userId!);

      setState(() => _profilePicture = publicUrl);

      if (mounted) {
        _showSuccess('¡Foto actualizada!');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al subir imagen: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro?',
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
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          NeonAlertDialog(title: '✅ Éxito', message: message, isSuccess: true),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => NeonAlertDialog(
        title: '❌ Error',
        message: message,
        iconColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppColors.cardBackground,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final rankInfo = RankUtils.getRankInfo(_activityPoints);
    final nextRank = RankUtils.getNextRank(_activityPoints);
    final progress = RankUtils.getProgressToNextRank(_activityPoints);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('👤 Mi Perfil'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto de perfil con efecto de rango
            Stack(
              alignment: Alignment.center,
              children: [
                RankProfilePicture(
                  imageUrl: _profilePicture,
                  activityPoints: _activityPoints,
                  size: 150,
                ),
                if (_isLoadingImage)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón cambiar foto
            ElevatedButton.icon(
              onPressed: _isLoadingImage ? null : _pickAndUploadImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cambiar Foto 📷'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Botón Premium (solo si no es premium)
            if (!_isPremium)
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/premium');
                  },
                  icon: const Icon(Icons.star, color: Colors.black),
                  label: const Text(
                    '⭐ Hazte Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Detalles del perfil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: rankInfo.color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rankInfo.color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Username
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: rankInfo.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '@$_username',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: rankInfo.color,
                        shadows: [
                          Shadow(
                            color: rankInfo.color.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rango
                  Text(
                    rankInfo.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: rankInfo.color,
                      shadows: [
                        Shadow(
                          color: rankInfo.color.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Puntos
                  Text(
                    '✨ Puntos de Actividad: $_activityPoints',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Barra de progreso
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation(rankInfo.color),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (nextRank != null)
                        Text(
                          'Próximo: ${nextRank.title} (${nextRank.minPoints} pts)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        )
                      else
                        Text(
                          '¡Rango máximo alcanzado! 🎉',
                          style: TextStyle(
                            color: rankInfo.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Biografía
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 Sobre mí:',
                        style: TextStyle(
                          color: rankInfo.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 200,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Escribe algo sobre ti...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: Colors.black87,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: rankInfo.color,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: rankInfo.color.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: rankInfo.color,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateDescription,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar 💾'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rankInfo.color.withOpacity(0.2),
                          foregroundColor: rankInfo.color,
                          side: BorderSide(color: rankInfo.color, width: 1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Email
                  Text(
                    'Email: $_email',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Sección de insignias
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎖️ Insignias Obtenidas (${_badges.length})',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_badges.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '¡Aún no has ganado insignias!\nVisita tu primer lugar para empezar 🚀',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: _badges.map((badgeEntry) {
                        final badge =
                            badgeEntry['badge'] as Map<String, dynamic>;
                        return Container(
                          width: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Column(
                            children: [
                              Text(
                                badge['icon_url'] ?? '🌟',
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                badge['name'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                badge['criteria'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Banner ad para usuarios no premium
            if (!_isPremium)
              const Padding(
                padding: EdgeInsets.only(top: 30, bottom: 10),
                child: AdBannerWidget(),
              ),
          ],
        ),
      ),
    );
  }
}
