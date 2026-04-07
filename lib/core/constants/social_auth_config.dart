class SocialAuthConfig {
  SocialAuthConfig._();

  // TODO: 네이버 개발자센터(https://developers.naver.com)에서 앱 등록 후 교체
  static const naverClientId = 'YOUR_NAVER_CLIENT_ID';
  static const naverClientSecret = 'YOUR_NAVER_CLIENT_SECRET';
  static const naverClientName = '지름막';

  // TODO: 카카오 개발자센터(https://developers.kakao.com)에서 앱 등록 후 교체
  static const kakaoNativeAppKey = 'YOUR_KAKAO_NATIVE_APP_KEY';

  // Firebase Cloud Functions 엔드포인트
  // TODO: Cloud Functions 배포 후 실제 URL로 교체
  static const socialLoginFunctionUrl =
      'https://us-central1-pause72-31936.cloudfunctions.net/socialLogin';
}
