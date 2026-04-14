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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0D14), Color(0xFF0F1828), Color(0xFF1A2E50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // 배경 글로우 (스플래시 스타일)
            Positioned(
              top: -80,
              right: -60,
              child: _GlowCircle(
                color: const Color(0xFF4D8FE8),
                size: 260,
                opacity: 0.12,
              ),
            ),
            Positioned(
              bottom: 60,
              left: -80,
              child: _GlowCircle(
                color: const Color(0xFF2D6FD4),
                size: 220,
                opacity: 0.08,
              ),
            ),
            Positioned(
              top: 200,
              right: 20,
              child: _GlowCircle(
                color: const Color(0xFF7BB8F0),
                size: 100,
                opacity: 0.07,
              ),
            ),
            // 본문
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    // 72H 로고 박스
                    const _IconBox(),
                    const SizedBox(height: 24),
                    // 브랜드명 (지름 + 막 컬러 분리)
                    const _BrandTitle(),
                    const SizedBox(height: 20),
                    // 감성 카피
                    Text(
                      AppStrings.splashLine1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8EA6C4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.splashLine2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFADC9E8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(flex: 3),
                    // 로그인 CTA
                    const Text(
                      '간편하게 시작하기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4E5E7A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Google 버튼
                    _LoginButton.google(
                      isLoading: isLoading,
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                    ),
                    const SizedBox(height: 12),
                    // 카카오 버튼
                    _LoginButton.kakao(
                      isLoading: isLoading,
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).signInWithKakao(),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 가로형 소셜 로그인 버튼
// ─────────────────────────────────────────────

enum _SocialProvider { google, kakao }

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.provider,
    required this.onPressed,
    required this.isLoading,
  });

  factory _LoginButton.google({
    required VoidCallback onPressed,
    required bool isLoading,
  }) =>
      _LoginButton(
        provider: _SocialProvider.google,
        onPressed: onPressed,
        isLoading: isLoading,
      );

  factory _LoginButton.kakao({
    required VoidCallback onPressed,
    required bool isLoading,
  }) =>
      _LoginButton(
        provider: _SocialProvider.kakao,
        onPressed: onPressed,
        isLoading: isLoading,
      );

  final _SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  Color get _bgColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF1A2130),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Color get _borderColor => switch (provider) {
        _SocialProvider.google => const Color(0xFF252C3E),
        _SocialProvider.kakao => const Color(0xFFFEE500),
      };

  Color get _textColor => switch (provider) {
        _SocialProvider.google => const Color(0xFFDDE9F7),
        _SocialProvider.kakao => const Color(0xFF1A1200),
      };

  String get _label => switch (provider) {
        _SocialProvider.google => 'Google로 계속하기',
        _SocialProvider.kakao => '카카오로 계속하기',
      };

  Widget get _icon => switch (provider) {
        _SocialProvider.google => SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
        _SocialProvider.kakao => const _KakaoLogo(),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: provider == _SocialProvider.google
                        ? const Color(0xFF4D8FE8)
                        : const Color(0xFF1A1200),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _icon,
                    const SizedBox(width: 12),
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 72H 아이콘 박스 (스플래시와 동일)
// ─────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D8FE8), Color(0xFF2354B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D8FE8).withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '72',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Text(
              'HOURS',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                color: Color(0xFFBDD5F5),
                letterSpacing: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 브랜드명 ("지름" + "막" 컬러 분리)
// ─────────────────────────────────────────────

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
        ),
        children: [
          TextSpan(
            text: '지름',
            style: TextStyle(color: Color(0xFFDDE9F7)),
          ),
          TextSpan(
            text: '막',
            style: TextStyle(color: Color(0xFF5BA4F5)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 배경 글로우 원
// ─────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
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
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
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
        fontSize: 18,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}
