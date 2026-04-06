import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/explore/presentation/pages/explore_page.dart';
import '../../../../features/home/domain/models/wish_stats.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wishStatsProvider);
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.valueOrNull;
    final isLoggedIn = user != null;
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
              GestureDetector(
                onTap: user == null ? () => context.go('/login') : null,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      // 프로필 사진
                      ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: user?.photoUrl != null
                            ? Image.network(
                                user!.photoUrl!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _DefaultAvatar(colors: colors),
                              )
                            : _DefaultAvatar(colors: colors),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? '로그인이 필요해요',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'Google 로그인으로 데이터를 보관하세요',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user == null)
                        Icon(Icons.chevron_right, color: colors.inactive, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _StatsSummaryCard(stats: stats),
              const SizedBox(height: 24),
              _SectionTitle('배움', colors: colors),
              const SizedBox(height: 10),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.menu_book_rounded,
                    label: '배움',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _LearnDetailPage()),
                    ),
                  ),
                ],
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
                  if (isLoggedIn)
                    _SettingsItem(
                      icon: Icons.logout_rounded,
                      label: '로그아웃',
                      labelColor: AppColors.red,
                      onTap: () => _showLogoutDialog(context, ref),
                    )
                  else
                    _SettingsItem(
                      icon: Icons.login_rounded,
                      label: 'Google로 로그인',
                      onTap: () => context.go('/login'),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '지름막 · 충동구매를 막는 72시간의 습관',
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('로그아웃', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatsSummaryCard extends StatelessWidget {
  const _StatsSummaryCard({required this.stats});
  final WishStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.gradStart, colors.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 절약 금액',
                  style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w500, letterSpacing: 0.4),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.savedAmount == 0 ? '₩ 0원' : stats.formattedSaved,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _SummaryItem(label: '참음', value: '${stats.cancelledCount}번', color: AppColors.blue),
                _Divider(),
                _SummaryItem(label: '구매', value: '${stats.purchasedCount}번', color: AppColors.green),
                _Divider(),
                _SummaryItem(label: '총 등록', value: '${stats.totalCount}개', color: AppColors.accent),
              ],
            ),
            if (stats.decidedCount > 0) ...[
              const SizedBox(height: 16),
              Divider(color: AppColors.accent.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '충동구매 저항률',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  Text(
                    '${(stats.saveRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stats.saveRate,
                  minHeight: 6,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ],
        ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: colors.surface2,
      child: Icon(Icons.person_outline, color: colors.inactive, size: 26),
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
    final colors = context.colors;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.center),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, color: colors.textTertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: context.colors.border);
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
                  icon: Icons.light_mode_rounded,
                  selected: !isDark,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setLight(),
                ),
                const SizedBox(width: 4),
                _ThemeSegment(
                  icon: Icons.dark_mode_rounded,
                  selected: isDark,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setDark(),
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
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
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
        child: Icon(icon, size: 16, color: selected ? Colors.white : colors.inactive),
      ),
    );
  }
}

class _LearnDetailPage extends StatelessWidget {
  const _LearnDetailPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '배움',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: const ExploreContent(),
      ),
    );
  }
}

