// lib/core/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('es', 'MX'); // Default: Español México

  Locale get locale => _locale;

  static const List<LocaleInfo> supportedLocales = [
    LocaleInfo('es', 'MX', 'Español (México)', '🇲🇽'),
    LocaleInfo('en', 'US', 'English', '🇺🇸'),
    LocaleInfo('es', 'ES', 'Español (España)', '🇪🇸'),
    LocaleInfo('es', 'AR', 'Español (Argentina)', '🇦🇷'),
    LocaleInfo('es', 'CL', 'Español (Chile)', '🇨🇱'),
    LocaleInfo('es', 'CO', 'Español (Colombia)', '🇨🇴'),
    LocaleInfo('es', 'PE', 'Español (Perú)', '🇵🇪'),
    LocaleInfo('es', 'VE', 'Español (Venezuela)', '🇻🇪'),
  ];

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    final countryCode = prefs.getString('country_code') ?? 'MX';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    if (languageCode == _locale.languageCode &&
        countryCode == _locale.countryCode) {
      return;
    }

    _locale = Locale(languageCode, countryCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    await prefs.setString('country_code', countryCode);

    notifyListeners();
  }

  String getLocaleName() {
    for (var localeInfo in supportedLocales) {
      if (localeInfo.languageCode == _locale.languageCode &&
          localeInfo.countryCode == _locale.countryCode) {
        return localeInfo.name;
      }
    }
    return 'Español (México)';
  }

  String getLocaleFlag() {
    for (var localeInfo in supportedLocales) {
      if (localeInfo.languageCode == _locale.languageCode &&
          localeInfo.countryCode == _locale.countryCode) {
        return localeInfo.flag;
      }
    }
    return '🇲🇽';
  }
}

class LocaleInfo {
  final String languageCode;
  final String countryCode;
  final String name;
  final String flag;

  const LocaleInfo(this.languageCode, this.countryCode, this.name, this.flag);
}
