import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class InterstitialAdService {
  InterstitialAdService._();
  static final instance = InterstitialAdService._();

  InterstitialAd? _ad;

  void load() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              load();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              load();
            },
          );
        },
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  void show() => _ad?.show();

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
