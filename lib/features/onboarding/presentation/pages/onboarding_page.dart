import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_strings.dart';

const _kOnboardingKey = 'onboarding_complete';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageCtrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _pageCtrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
    if (!mounted) return;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    context.go(isLoggedIn ? '/main' : '/login');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              // ── 상단 Skip ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 80),
                    // 페이지 표시 (중앙)
                    Row(
                      children: List.generate(3, (i) {
                        final isActive = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF4D8FE8)
                                : const Color(0xFF252C3E),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text(
                            AppStrings.onboardingSkip,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4E5E7A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── 슬라이드 영역 ──────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    const _Slide1(),
                    const _Slide2(),
                    _Slide3(onStart: _finish),
                  ],
                ),
              ),
              // ── 하단 버튼 (슬라이드 1·2만, 3은 자체 CTA) ───
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: _page < 2
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                        child: _PrimaryButton(
                          label: AppStrings.onboardingNext,
                          onTap: _next,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 슬라이드 1: 문제 제기 + 카운트다운 ──────────────────────

class _Slide1 extends StatefulWidget {
  const _Slide1();

  @override
  State<_Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1> {
  static const _steps = [72, 48, 24];
  int _stepIdx = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _stepIdx = (_stepIdx + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _steps[_stepIdx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 72H 박스 (카운트다운 애니메이션)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4D8FE8), Color(0xFF2354B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4D8FE8).withValues(alpha: 0.50),
                  blurRadius: 40,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '$hours',
                    key: ValueKey(hours),
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'HOURS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBDD5F5),
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
          const Text(
            AppStrings.onboarding1Headline1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDDE9F7),
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.onboarding1Headline2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5BA4F5),
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            AppStrings.onboarding1Body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8EA6C4),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 슬라이드 2: 기능 소개 ─────────────────────────────────

class _Slide2 extends StatelessWidget {
  const _Slide2();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            AppStrings.onboarding2Headline,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDDE9F7),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.timer_outlined,
            color: const Color(0xFF4D8FE8),
            title: AppStrings.onboarding2Feature1Title,
            body: AppStrings.onboarding2Feature1Body,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFF34C78A),
            title: AppStrings.onboarding2Feature2Title,
            body: AppStrings.onboarding2Feature2Body,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.people_outline_rounded,
            color: const Color(0xFFFBBF24),
            title: AppStrings.onboarding2Feature3Title,
            body: AppStrings.onboarding2Feature3Body,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.savings_outlined,
            color: const Color(0xFFA78BFA),
            title: AppStrings.onboarding2Feature4Title,
            body: AppStrings.onboarding2Feature4Body,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF252C3E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDDE9F7),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8EA6C4),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 슬라이드 3: CTA ──────────────────────────────────────

class _Slide3 extends StatelessWidget {
  const _Slide3({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 별 모양 아이콘 (저축/절약)
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C78A), Color(0xFF1EA36A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34C78A).withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            AppStrings.onboarding3Headline1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDDE9F7),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppStrings.onboarding3Headline2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF34C78A),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            AppStrings.onboarding3Body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8EA6C4),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 52),
          _PrimaryButton(
            label: AppStrings.onboardingStart,
            onTap: onStart,
          ),
        ],
      ),
    );
  }
}

// ── 공통 버튼 ──────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D8FE8), Color(0xFF2D6FD4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4D8FE8).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
