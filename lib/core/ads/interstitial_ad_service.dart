import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class InterstitialAdService {
  InterstitialAdService._();
  static final instance = InterstitialAdService._();

  InterstitialAd? _ad;
  VoidCallback? _onDismissed;

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
              final cb = _onDismissed;
              _onDismissed = null;
              load();
              cb?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              final cb = _onDismissed;
              _onDismissed = null;
              load();
              cb?.call();
            },
          );
        },
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  /// 광고를 표시합니다.
  /// 광고가 없거나 닫힌 뒤 [onDismissed]가 호출됩니다.
  void show({VoidCallback? onDismissed}) {
    _onDismissed = onDismissed;
    if (_ad == null) {
      onDismissed?.call();
      _onDismissed = null;
      return;
    }
    _ad!.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
