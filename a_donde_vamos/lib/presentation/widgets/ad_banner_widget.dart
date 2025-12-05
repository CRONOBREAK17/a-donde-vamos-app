// lib/presentation/widgets/ad_banner_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../data/services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    if (!_adService.isBannerAdReady || _adService.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _adService.bannerAd!.size.width.toDouble(),
      height: _adService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _adService.bannerAd!),
    );
  }
}
