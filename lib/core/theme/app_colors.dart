import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surfaceHighlight,
    required this.gradStart,
    required this.gradEnd,
    required this.border,
    required this.borderLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.inactive,
  });

  final Color background;
  final Color surface;
  final Color surface2;
  final Color surfaceHighlight;
  final Color gradStart;
  final Color gradEnd;
  final Color border;
  final Color borderLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color inactive;

  // 테마 무관 공통 색상
  static const Color accent = Color(0xFF4D8FE8);   // 소프트 블루
  static const Color green = Color(0xFF34C78A);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF7BB8F0);

  static const AppColors dark = AppColors._(
    background: Color(0xFF0B0D14),   // 거의 블랙 + 블루 틴트
    surface: Color(0xFF141820),      // 카드/서피스
    surface2: Color(0xFF0F1118),
    surfaceHighlight: Color(0xFF1E2433), // 버튼/하이라이트
    gradStart: Color(0xFF111828),
    gradEnd: Color(0xFF0B1020),
    border: Color(0xFF252C3E),       // 선명한 구분선
    borderLight: Color(0xFF1C2230),
    textPrimary: Color(0xFFF0F4FF),  // 밝은 화이트
    textSecondary: Color(0xFF8898B5), // 중간 블루그레이
    textTertiary: Color(0xFF4E5E7A), // 어두운 블루그레이
    inactive: Color(0xFF2E3848),
  );

  static const AppColors light = AppColors._(
    background: Color(0xFFF5F2EE),   // 따뜻한 오프화이트
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFECE8E2),
    surfaceHighlight: Color(0xFFE6E0D8),
    gradStart: Color(0xFFEDE8DF),
    gradEnd: Color(0xFFDDD7CE),
    border: Color(0xFFD5CDBF),
    borderLight: Color(0xFFE4DED5),
    textPrimary: Color(0xFF1A2535),
    textSecondary: Color(0xFF4A6080),
    textTertiary: Color(0xFF8099B8),
    inactive: Color(0xFFAABECE),
  );
}

extension AppColorsX on BuildContext {
  AppColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppColors.dark : AppColors.light;
  }

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
