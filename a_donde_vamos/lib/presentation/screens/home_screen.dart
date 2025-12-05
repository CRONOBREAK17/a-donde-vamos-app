// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'friends_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const FavoritesScreen(),
    const FriendsScreen(),
    const RankingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: l10n.translate('explore'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.translate('history'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.translate('favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.translate('friends'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events),
            label: l10n.translate('ranking'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.translate('profile'),
          ),
        ],
      ),
    );
  }
}
