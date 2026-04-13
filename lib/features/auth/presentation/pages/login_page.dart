import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen(authNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // 로고
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7CF6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('🛑', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 3),
              // 로그인 버튼 영역
              const Text(
                AppStrings.loginContinueWith,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton.google(
                    isLoading: isLoading,
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  ),
                  const SizedBox(width: 20),
                  _SocialIconButton.kakao(
                    isLoading: isLoading,
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signInWithKakao(),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 아이콘 전용 소셜 로그인 버튼
// ─────────────────────────────────────────────

enum _SocialProvider { google, kakao }

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.provider,
    required this.onPressed,
    required this.isLoading,
  });

  factory _SocialIconButton.google({
    required VoidCallback onPressed,
    required bool isLoading,
  }) =>
      _SocialIconButton(
          provider: _SocialProvider.google,
          onPressed: onPressed,
          isLoading: isLoading);

  factory _SocialIconButton.kakao({
    required VoidCallback onPressed,
    required bool isLoading,
  }) =>
      _SocialIconButton(
          provider: _SocialProvider.kakao,
          onPressed: onPressed,
          isLoading: isLoading);

  final _SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  Color get _bgColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF1A1A1A),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Color get _borderColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF2E2E2E),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Widget get _icon => switch (provider) {
        _SocialProvider.google => SizedBox(
            width: 22,
            height: 22,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
        _SocialProvider.kakao => const _KakaoLogo(),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4D8FE8),
                  ),
                )
              : _icon,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 로고 위젯들
// ─────────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KakaoLogo extends StatelessWidget {
  const _KakaoLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'K',
      style: TextStyle(
        color: Color(0xFF1A1200),
        fontSize: 20,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}
