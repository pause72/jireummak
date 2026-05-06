import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_strings.dart';

const _kOnboardingKey = 'onboarding_complete';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // ── 인트로 애니메이션 (2000ms, one-shot) ─────────────────
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subFade;

  // ── 배경 float 애니메이션 (3000ms, repeat) ───────────────
  late final AnimationController _bgCtrl;
  late final Animation<double> _bgDrift;

  @override
  void initState() {
    super.initState();

    // 배경 float
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _bgDrift = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    // 인트로
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.elasticOut),
      ),
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.4)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    ));

    _subFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(_kOnboardingKey) ?? false;
      if (!mounted) return;
      if (!onboardingDone) {
        context.go('/onboarding');
        return;
      }
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      context.go(isLoggedIn ? '/main' : '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // ── 배경 float 원 ─────────────────────────────
            AnimatedBuilder(
              animation: _bgDrift,
              builder: (context, _) {
                final d = _bgDrift.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -80 + d * 22,
                      right: -60 + d * 12,
                      child: _GlowCircle(
                        color: const Color(0xFF4D8FE8),
                        size: 260,
                        opacity: 0.10 + d * 0.05,
                      ),
                    ),
                    Positioned(
                      bottom: 60 - d * 16,
                      left: -80 + d * 10,
                      child: _GlowCircle(
                        color: const Color(0xFF2D6FD4),
                        size: 220,
                        opacity: 0.06 + d * 0.04,
                      ),
                    ),
                    // 추가: 중앙 우상단 작은 원
                    Positioned(
                      top: 180 + d * 14,
                      right: 30 - d * 8,
                      child: _GlowCircle(
                        color: const Color(0xFF7BB8F0),
                        size: 100,
                        opacity: 0.05 + d * 0.04,
                      ),
                    ),
                  ],
                );
              },
            ),
            // ── 중앙 콘텐츠 ───────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘: "72H" 타이머 박스
                  FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: const _IconBox(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 브랜드명: "지름" + "막" 컬러 분리
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const _BrandTitle(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 카피: 질문형
                  FadeTransition(
                    opacity: _subFade,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.splashLine1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8EA6C4),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppStrings.splashLine2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFADC9E8),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── 하단 로딩 도트 ────────────────────────────
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _subFade,
                child: const _LoadingDots(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 72H 아이콘 박스 ────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D8FE8), Color(0xFF2354B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D8FE8).withValues(alpha: 0.55),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '72',
            style: TextStyle(
              fontSize: 36,
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
                fontSize: 8,
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

// ── 브랜드명 ("지름" + "막" 컬러 분리) ────────────────────

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 44,
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

// ── 배경 글로우 원 ─────────────────────────────────────────

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

// ── 로딩 도트 ─────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value - i * 0.2) % 1.0);
            final scale = 0.5 + 0.5 * sin(phase * pi).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4D8FE8).withValues(alpha: 0.6 + 0.4 * scale),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
