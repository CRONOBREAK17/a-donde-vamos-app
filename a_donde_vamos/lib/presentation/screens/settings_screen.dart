// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          '⚙️ ${localizations.translate('settings')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Tema
            _buildSectionTitle(
              context,
              Icons.palette,
              localizations.translate('theme'),
            ),
            const SizedBox(height: 15),
            _buildThemeSelector(context, settingsProvider, localizations),

            const SizedBox(height: 30),

            // Sección de Idioma
            _buildSectionTitle(
              context,
              Icons.language,
              localizations.translate('language'),
            ),
            const SizedBox(height: 15),
            _buildLanguageSelector(context, settingsProvider, localizations),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations localizations,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            settingsProvider,
            localizations,
            ThemeMode.dark,
            Icons.dark_mode,
            localizations.translate('dark_theme'),
          ),
          Divider(height: 1, color: AppColors.primary.withOpacity(0.2)),
          _buildThemeOption(
            context,
            settingsProvider,
            localizations,
            ThemeMode.light,
            Icons.light_mode,
            localizations.translate('light_theme'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations localizations,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = settingsProvider.themeMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => settingsProvider.setThemeMode(mode),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 28,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations localizations,
  ) {
    final languages = [
      {
        'code': 'es_MX',
        'name': '🇲🇽 Español (México)',
        'locale': const Locale('es', 'MX'),
      },
      {
        'code': 'en_US',
        'name': '🇺🇸 English (US)',
        'locale': const Locale('en', 'US'),
      },
      {
        'code': 'es_ES',
        'name': '🇪🇸 Español (España)',
        'locale': const Locale('es', 'ES'),
      },
      {
        'code': 'es_AR',
        'name': '🇦🇷 Español (Argentina)',
        'locale': const Locale('es', 'AR'),
      },
      {
        'code': 'es_CL',
        'name': '🇨🇱 Español (Chile)',
        'locale': const Locale('es', 'CL'),
      },
      {
        'code': 'es_CO',
        'name': '🇨🇴 Español (Colombia)',
        'locale': const Locale('es', 'CO'),
      },
      {
        'code': 'es_PE',
        'name': '🇵🇪 Español (Perú)',
        'locale': const Locale('es', 'PE'),
      },
      {
        'code': 'es_VE',
        'name': '🇻🇪 Español (Venezuela)',
        'locale': const Locale('es', 'VE'),
      },
      {
        'code': 'es_EC',
        'name': '🇪🇨 Español (Ecuador)',
        'locale': const Locale('es', 'EC'),
      },
      {
        'code': 'es_BO',
        'name': '🇧🇴 Español (Bolivia)',
        'locale': const Locale('es', 'BO'),
      },
      {
        'code': 'es_PY',
        'name': '🇵🇾 Español (Paraguay)',
        'locale': const Locale('es', 'PY'),
      },
      {
        'code': 'es_UY',
        'name': '🇺🇾 Español (Uruguay)',
        'locale': const Locale('es', 'UY'),
      },
      {
        'code': 'es_CR',
        'name': '🇨🇷 Español (Costa Rica)',
        'locale': const Locale('es', 'CR'),
      },
      {
        'code': 'es_PA',
        'name': '🇵🇦 Español (Panamá)',
        'locale': const Locale('es', 'PA'),
      },
      {
        'code': 'es_CU',
        'name': '🇨🇺 Español (Cuba)',
        'locale': const Locale('es', 'CU'),
      },
      {
        'code': 'es_DO',
        'name': '🇩🇴 Español (Rep. Dominicana)',
        'locale': const Locale('es', 'DO'),
      },
      {
        'code': 'es_PR',
        'name': '🇵🇷 Español (Puerto Rico)',
        'locale': const Locale('es', 'PR'),
      },
      {
        'code': 'es_GT',
        'name': '🇬🇹 Español (Guatemala)',
        'locale': const Locale('es', 'GT'),
      },
      {
        'code': 'es_HN',
        'name': '🇭🇳 Español (Honduras)',
        'locale': const Locale('es', 'HN'),
      },
      {
        'code': 'es_SV',
        'name': '🇸🇻 Español (El Salvador)',
        'locale': const Locale('es', 'SV'),
      },
      {
        'code': 'es_NI',
        'name': '🇳🇮 Español (Nicaragua)',
        'locale': const Locale('es', 'NI'),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: languages.asMap().entries.map((entry) {
          final index = entry.key;
          final lang = entry.value;
          final locale = lang['locale'] as Locale;
          final isSelected =
              settingsProvider.locale.languageCode == locale.languageCode &&
              settingsProvider.locale.countryCode == locale.countryCode;

          return Column(
            children: [
              if (index > 0)
                Divider(height: 1, color: AppColors.primary.withOpacity(0.1)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => settingsProvider.setLocale(locale),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang['name'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
