import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                '지름막',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8E8E8),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '충동구매를 막는 72시간의 습관',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 3),
              // 로그인 버튼 영역
              const Text(
                'SNS 계정으로 계속하기',
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
                  _SocialIconButton.naver(
                    isLoading: isLoading,
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signInWithNaver(),
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

enum _SocialProvider { google, naver, kakao }

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.provider,
    required this.onPressed,
    required this.isLoading,
    this.disabled = false,
  });

  factory _SocialIconButton.google({
    required VoidCallback onPressed,
    required bool isLoading,
  }) =>
      _SocialIconButton(
          provider: _SocialProvider.google,
          onPressed: onPressed,
          isLoading: isLoading);

  factory _SocialIconButton.naver({
    required VoidCallback onPressed,
    required bool isLoading,
    bool disabled = false,
  }) =>
      _SocialIconButton(
          provider: _SocialProvider.naver,
          onPressed: onPressed,
          isLoading: isLoading,
          disabled: disabled);

  factory _SocialIconButton.kakao({
    required VoidCallback onPressed,
    required bool isLoading,
    bool disabled = false,
  }) =>
      _SocialIconButton(
          provider: _SocialProvider.kakao,
          onPressed: onPressed,
          isLoading: isLoading,
          disabled: disabled);

  final _SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool disabled;

  Color get _bgColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF1A1A1A),
        _SocialProvider.naver => const Color(0xFF03C75A),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Color get _borderColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF2E2E2E),
        _SocialProvider.naver => const Color(0xFF03C75A),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Widget get _icon => switch (provider) {
        _SocialProvider.google => SizedBox(
            width: 22,
            height: 22,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
        _SocialProvider.naver => const _NaverLogo(),
        _SocialProvider.kakao => const _KakaoLogo(),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : onPressed,
      child: Opacity(
        opacity: disabled ? 0.35 : 1.0,
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

class _NaverLogo extends StatelessWidget {
  const _NaverLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'N',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
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
