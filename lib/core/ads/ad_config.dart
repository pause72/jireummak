import 'dart:io';

/// TODO: AdMob 콘솔에서 실제 앱 등록 후 테스트 ID를 실제 ID로 교체하세요
/// - iOS 앱 ID:     Info.plist > GADApplicationIdentifier
/// - Android 앱 ID: AndroidManifest.xml > com.google.android.gms.ads.APPLICATION_ID
class AdConfig {
  AdConfig._();

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9892920356540798/1203274797'
      : 'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  // TODO: Play Store 게시 후 실제 ID로 교체 — ca-app-pub-9892920356540798/5997045287
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9892920356540798/5997045287'
      : 'ca-app-pub-3940256099942544/3986624511';

  // TODO: Play Store 게시 후 실제 ID로 교체 — ca-app-pub-9892920356540798/7534475318
  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-9892920356540798/7534475318'
      : 'ca-app-pub-3940256099942544/1712485313';
}
