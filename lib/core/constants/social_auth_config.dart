class SocialAuthConfig {
  SocialAuthConfig._();

  // TODO: 카카오 개발자센터(https://developers.kakao.com)에서 앱 등록 후 교체
  static const kakaoNativeAppKey = 'YOUR_KAKAO_NATIVE_APP_KEY';

  // Firebase Cloud Functions 엔드포인트
  // TODO: Cloud Functions 배포 후 실제 URL로 교체
  static const socialLoginFunctionUrl =
      'https://us-central1-pause72-31936.cloudfunctions.net/socialLogin';
}
