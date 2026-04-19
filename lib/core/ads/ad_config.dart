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

  // TODO: AdMob 콘솔에서 Native 타입 광고 유닛 생성 후 아래 Android ID를 교체하세요
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110' // 테스트 ID — 실제 Native 유닛 ID로 교체 필요
      : 'ca-app-pub-3940256099942544/3986624511';

  // TODO: AdMob 콘솔에서 리워드 광고 ID로 교체하세요
  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // 테스트 ID
      : 'ca-app-pub-3940256099942544/1712485313'; // 테스트 ID
}
