import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/domain/models/user_model.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/main/presentation/pages/main_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authNotifier = ValueNotifier<bool?>(null); // null=loading, true=logged in, false=logged out

  void update(AsyncValue<UserModel?> authState) {
    switch (authState) {
      case AsyncLoading():
        authNotifier.value = null;
      case AsyncData(:final value):
        authNotifier.value = value != null;
      case AsyncError():
        authNotifier.value = false;
    }
  }

  update(ref.read(authStateProvider));
  ref.listen(authStateProvider, (_, next) => update(next));

  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoading = authNotifier.value == null;
      final isLoggedIn = authNotifier.value == true;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;
      if (loc == '/onboarding') return null; // 온보딩은 인증 없이 접근 허용
      if (isLoading) return null;
      if (!isLoggedIn && loc != '/login') return '/login';
      if (isLoggedIn && loc == '/login') return '/main';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainPage(),
      ),
    ],
  );
}
