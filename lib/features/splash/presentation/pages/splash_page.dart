import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _subFade;
  late final Animation<Offset> _logoSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _subFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: SlideTransition(
                position: _logoSlide,
                child: _Logo(),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _subFade,
              child: _Subtitle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // pause ∥ icon
        const Icon(
          Icons.pause_circle_outline_rounded,
          size: 64,
          color: Color(0xFFE8E8E8),
        ),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'pause',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFE8E8E8),
                  letterSpacing: 6,
                ),
              ),
              TextSpan(
                text: '72',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B7CF6),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          '사기 전에 72시간,',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF888888),
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '진짜 필요한지 생각해보세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF888888),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
