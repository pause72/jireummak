import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/ads/interstitial_ad_service.dart';
import 'core/ads/rewarded_ad_service.dart';
import 'core/constants/social_auth_config.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: SocialAuthConfig.kakaoNativeAppKey);
  await MobileAds.instance.initialize();
  await NotificationService().initialize();
  InterstitialAdService.instance.load();
  RewardedAdService.instance.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((_) => Future.value(prefs)),
      ],
      child: const App(),
    ),
  );
}
