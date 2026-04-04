import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wishStatsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 프로필
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: colors.inactive,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '로그인이 필요해요',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Google 로그인으로 데이터를 보관하세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colors.inactive,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 요약 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.gradStart, colors.gradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: '참은 횟수',
                        value: '${stats.cancelledCount}번',
                        color: AppColors.green,
                      ),
                    ),
                    Container(width: 1, height: 40, color: colors.border),
                    Expanded(
                      child: _SummaryItem(
                        label: '대기 중',
                        value: '${stats.waitingCount}개',
                        color: AppColors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('설정', colors: colors),
              const SizedBox(height: 10),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.notifications_none_rounded,
                    label: '알림 설정',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _ThemeToggleCard(),
              const SizedBox(height: 24),
              _SectionTitle('앱 정보', colors: colors),
              const SizedBox(height: 10),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: '버전',
                    trailing: '1.0.0',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: '이용약관',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보 처리방침',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: '로그아웃',
                    labelColor: AppColors.red,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'pause72 · 충동구매를 멈추는 72시간의 습관',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.border,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('로그아웃', style: TextStyle(color: colors.textPrimary, fontSize: 16)),
        content: Text('로그아웃 하시겠어요?', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); context.go('/login'); },
            child: const Text('로그아웃', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF666666)), textAlign: TextAlign.center),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.colors});
  final String title;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textTertiary, letterSpacing: 0.5),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items, required this.colors});

  final List<_SettingsItem> items;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.borderLight, indent: 52),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: labelColor ?? colors.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: labelColor ?? colors.textPrimary),
              ),
            ),
            if (trailing != null) ...[
              Text(trailing!, style: TextStyle(fontSize: 13, color: colors.textTertiary)),
              const SizedBox(width: 4),
            ],
            if (labelColor == null)
              Icon(Icons.chevron_right, size: 18, color: colors.inactive),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleCard extends ConsumerWidget {
  const _ThemeToggleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 20,
            color: isDark ? AppColors.accent : AppColors.yellow,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('테마', style: TextStyle(fontSize: 14, color: colors.textPrimary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _ThemeSegment(
                  icon: Icons.dark_mode_rounded,
                  label: '다크',
                  selected: isDark,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setDark(),
                ),
                const SizedBox(width: 4),
                _ThemeSegment(
                  icon: Icons.light_mode_rounded,
                  label: '라이트',
                  selected: !isDark,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setLight(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? Colors.white : colors.inactive),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : colors.inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
