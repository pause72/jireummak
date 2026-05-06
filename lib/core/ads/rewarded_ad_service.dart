import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class RewardedAdService {
  RewardedAdService._();
  static final instance = RewardedAdService._();

  RewardedAd? _ad;
  bool _isLoading = false;

  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[RewardedAdService] load failed: $error');
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  bool get isReady => _ad != null;

  /// 광고를 표시합니다.
  /// [onRewarded]: 광고 시청 완료 후 보상 지급 시 호출
  /// [onDismissed]: 광고가 닫혔을 때 호출 (보상 여부 무관)
  /// [onNotAvailable]: 광고가 준비되지 않았을 때 호출
  void show({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onNotAvailable,
  }) {
    if (_ad == null) {
      onNotAvailable?.call();
      load();
      return;
    }

    bool rewarded = false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load();
        onDismissed?.call();
        if (rewarded) onRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[RewardedAdService] show failed: $error');
        ad.dispose();
        _ad = null;
        load();
        onNotAvailable?.call();
      },
    );

    _ad!.show(
      onUserEarnedReward: (ad, reward) => rewarded = true,
    );
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
