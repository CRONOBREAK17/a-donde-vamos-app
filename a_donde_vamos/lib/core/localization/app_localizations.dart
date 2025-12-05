// lib/core/localization/app_localizations.dart
import 'package:flutter/material.dart';
import 'languages/es_mx.dart';
import 'languages/es_es.dart';
import 'languages/es_ar.dart';
import 'languages/es_cl.dart';
import 'languages/es_co.dart';
import 'languages/es_pe.dart';
import 'languages/es_ve.dart';
import 'languages/en_us.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale) {
    _localizedStrings = _getTranslations(locale);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _getTranslations(Locale locale) {
    switch (locale.toString()) {
      case 'es_MX':
        return esMX;
      case 'es_ES':
        return esES;
      case 'es_AR':
        return esAR;
      case 'es_CL':
        return esCL;
      case 'es_CO':
        return esCO;
      case 'es_PE':
        return esPE;
      case 'es_VE':
        return esVE;
      case 'en_US':
        return enUS;
      default:
        return esMX;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getter methods for easy access
  String get appName => translate('app_name');

  // Bottom Navigation
  String get navExplore => translate('nav_explore');
  String get navHistory => translate('nav_history');
  String get navFavorites => translate('nav_favorites');
  String get navFriends => translate('nav_friends');
  String get navRanking => translate('nav_ranking');
  String get navProfile => translate('nav_profile');

  // Common
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get accept => translate('accept');
  String get save => translate('save');
  String get close => translate('close');
  String get search => translate('search');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get yes => translate('yes');
  String get no => translate('no');

  // Dashboard
  String get exploreTitle => translate('explore_title');
  String get searchPlaces => translate('search_places');
  String get nearbyPlaces => translate('nearby_places');
  String get alreadyVisited => translate('already_visited');
  String get viewDetails => translate('view_details');
  String get openInMaps => translate('open_in_maps');
  String get noPlacesFound => translate('no_places_found');

  // Place Details
  String get reviews => translate('reviews');
  String get addReview => translate('add_review');
  String get yourOpinion => translate('your_opinion');
  String get writeReview => translate('write_review');
  String get rating => translate('rating');
  String get visitedPlace => translate('visited_place');
  String get markAsVisited => translate('mark_as_visited');

  // Profile
  String get myProfile => translate('my_profile');
  String get editProfile => translate('edit_profile');
  String get activityPoints => translate('activity_points');
  String get achievements => translate('achievements');
  String get viewAchievements => translate('view_achievements');
  String get biography => translate('biography');
  String get logout => translate('logout');

  // Achievements
  String get achievementsTitle => translate('achievements_title');
  String get achievementUnlocked => translate('achievement_unlocked');
  String get unlockedAchievements => translate('unlocked_achievements');
  String get noAchievementsYet => translate('no_achievements_yet');

  // Premium
  String get goPremium => translate('go_premium');
  String get premiumBenefits => translate('premium_benefits');
  String get noAds => translate('no_ads');
  String get unlimitedSearch => translate('unlimited_search');
  String get advancedFilters => translate('advanced_filters');
  String get exclusiveBadge => translate('exclusive_badge');
  String get prioritySupport => translate('priority_support');

  // Settings
  String get settings => translate('settings');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get changeLanguage => translate('change_language');
  String get languageChanged => translate('language_changed');

  // Friends
  String get friendsTitle => translate('friends_title');
  String get addFriend => translate('add_friend');
  String get searchFriends => translate('search_friends');
  String get noFriends => translate('no_friends');

  // Ranking
  String get rankingTitle => translate('ranking_title');
  String get topUsers => translate('top_users');
  String get yourPosition => translate('your_position');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'es_MX',
      'es_ES',
      'es_AR',
      'es_CL',
      'es_CO',
      'es_PE',
      'es_VE',
      'en_US',
    ].contains(locale.toString());
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
