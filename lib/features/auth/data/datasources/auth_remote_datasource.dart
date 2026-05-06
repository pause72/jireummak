import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/social_auth_config.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(
    FirebaseAuth.instance,
    GoogleSignIn(),
  );
}

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  // ── Google ────────────────────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google 로그인이 취소되었습니다.');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  // ── Kakao ─────────────────────────────────────────────
  Future<UserCredential> signInWithKakao() async {
    String accessToken;

    // 카카오톡 앱 설치 여부에 따라 분기
    if (await kakao.isKakaoTalkInstalled()) {
      final token = await kakao.UserApi.instance.loginWithKakaoTalk();
      accessToken = token.accessToken;
    } else {
      final token = await kakao.UserApi.instance.loginWithKakaoAccount();
      accessToken = token.accessToken;
    }

    final firebaseToken = await _getFirebaseCustomToken(
      provider: 'kakao',
      accessToken: accessToken,
    );
    return _firebaseAuth.signInWithCustomToken(firebaseToken);
  }

  // ── Firebase Custom Token 요청 ────────────────────────
  Future<String> _getFirebaseCustomToken({
    required String provider,
    required String accessToken,
  }) async {
    final response = await http.post(
      Uri.parse(SocialAuthConfig.socialLoginFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'provider': provider, 'accessToken': accessToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('소셜 로그인 서버 오류: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['firebaseToken'] as String?;
    if (token == null) throw Exception('토큰 발급 실패');
    return token;
  }

  // ── Sign Out ──────────────────────────────────────────
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    // 카카오 로그아웃
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }
}
