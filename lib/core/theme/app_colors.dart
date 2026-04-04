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
  static const Color accent = Color(0xFF8B7CF6);
  static const Color green = Color(0xFF4ADE80);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF60A5FA);

  static const AppColors dark = AppColors._(
    background: Color(0xFF0F0F0F),
    surface: Color(0xFF1A1A1A),
    surface2: Color(0xFF141414),
    surfaceHighlight: Color(0xFF222222),
    gradStart: Color(0xFF1E1A2E),
    gradEnd: Color(0xFF16133A),
    border: Color(0xFF2A2A2A),
    borderLight: Color(0xFF222222),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF888888),
    textTertiary: Color(0xFF555555),
    inactive: Color(0xFF444444),
  );

  static const AppColors light = AppColors._(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEFEFF4),
    surfaceHighlight: Color(0xFFE8E8F0),
    gradStart: Color(0xFFEEE8FF),
    gradEnd: Color(0xFFE0D8FF),
    border: Color(0xFFDDDDDD),
    borderLight: Color(0xFFEAEAEA),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF666666),
    textTertiary: Color(0xFF999999),
    inactive: Color(0xFFBBBBBB),
  );
}

extension AppColorsX on BuildContext {
  AppColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppColors.dark : AppColors.light;
  }

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
