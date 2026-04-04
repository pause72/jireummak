import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // 로고
              const Icon(
                Icons.pause_circle_outline_rounded,
                size: 56,
                color: Color(0xFFE8E8E8),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'pause',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFE8E8E8),
                        letterSpacing: 6,
                      ),
                    ),
                    TextSpan(
                      text: '72',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B7CF6),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '충동구매를 멈추는 72시간의 습관',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 3),
              // 구글 로그인 버튼
              _GoogleSignInButton(
                onPressed: () => context.go('/main'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0xFF2E2E2E)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 'G' 로고
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Google로 계속하기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8E8E8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 배경 원
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
