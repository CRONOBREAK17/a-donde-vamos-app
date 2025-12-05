// lib/core/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('es', 'MX'); // México por defecto

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar tema
    final themeModeString = prefs.getString('theme_mode') ?? 'dark';
    _themeMode = themeModeString == 'light' ? ThemeMode.light : ThemeMode.dark;

    // Cargar idioma
    final languageCode = prefs.getString('language_code') ?? 'es';
    final countryCode = prefs.getString('country_code') ?? 'MX';
    _locale = Locale(languageCode, countryCode);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}
