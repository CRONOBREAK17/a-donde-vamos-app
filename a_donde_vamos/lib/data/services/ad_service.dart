// lib/data/services/ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // IDs de prueba (REEMPLAZAR con tus IDs reales de AdMob)
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Banner Ad Test ID
  static const String _bannerAdUnitId = kReleaseMode
      ? 'TU_BANNER_AD_UNIT_ID' // Reemplazar con tu ID real
      : 'ca-app-pub-3940256099942544/6300978111'; // Test ID

  // Interstitial Ad Test ID
  static const String _interstitialAdUnitId = kReleaseMode
      ? 'TU_INTERSTITIAL_AD_UNIT_ID' // Reemplazar con tu ID real
      : 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  // Rewarded Ad Test ID
  static const String _rewardedAdUnitId = kReleaseMode
      ? 'TU_REWARDED_AD_UNIT_ID' // Reemplazar con tu ID real
      : 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  int _searchCount = 0;
  static const int _interstitialFrequency = 3; // Mostrar cada 3 búsquedas

  // Inicializar AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('✅ AdMob inicializado');
  }

  // Crear Banner Ad
  void createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad cargado');
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Error cargando banner: $error');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Crear Interstitial Ad
  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Interstitial ad cargado');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial cerrado');
              ad.dispose();
              _isInterstitialAdReady = false;
              createInterstitialAd(); // Precargar el siguiente
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Error mostrando interstitial: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              createInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Error cargando interstitial: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Mostrar Interstitial Ad cada X búsquedas
  void showInterstitialIfReady() {
    _searchCount++;

    if (_searchCount % _interstitialFrequency == 0) {
      if (_isInterstitialAdReady && _interstitialAd != null) {
        _interstitialAd!.show();
        _isInterstitialAdReady = false;
      } else {
        debugPrint('Interstitial no listo, precargando...');
        createInterstitialAd();
      }
    }
  }

  // Crear Rewarded Ad (para futuras funcionalidades)
  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad cargado');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Error cargando rewarded: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // Mostrar Rewarded Ad con callback de recompensa
  void showRewardedAd({required Function(int) onUserEarnedReward}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdReady = false;
          createRewardedAd(); // Precargar el siguiente
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdReady = false;
          createRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('Usuario ganó recompensa: ${reward.amount}');
          onUserEarnedReward(reward.amount.toInt());
        },
      );
    }
  }

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;

  // Dispose
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
