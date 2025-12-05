// lib/data/services/ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // IDs de prueba (REEMPLAZAR con tus IDs reales de AdMob)
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Banner Ad ID (aparece en dashboard y otras pantallas)
  static const String _bannerAdUnitId =
      'ca-app-pub-5953435941236720/2633441735';

  // Interstitial Ad ID (pantalla completa cada 3 búsquedas)
  static const String _interstitialAdUnitId =
      'ca-app-pub-5953435941236720/2555859613';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;

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

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;

  // Dispose
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
