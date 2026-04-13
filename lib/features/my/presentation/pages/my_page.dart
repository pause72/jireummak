import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_policy_strings.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/explore/presentation/pages/explore_page.dart';
import '../../../../features/home/domain/models/wish_stats.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';
import '../../domain/models/savings_goal.dart';
import '../providers/nickname_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/savings_goal_provider.dart';

// 만원/억원 단위로 축약 (예: 12,340,000 → 1,234만원)
String _shortAmount(int amount) {
  if (amount <= 0) return '0원';
  if (amount >= 100000000) {
    final eok = amount / 100000000;
    final str = eok % 1 == 0 ? eok.toInt().toString() : eok.toStringAsFixed(1);
    return '$str억원';
  }
  if (amount >= 10000) {
    final man = amount / 10000;
    final str = man % 1 == 0 ? man.toInt().toString() : man.toStringAsFixed(1);
    return '$str만원';
  }
  return '$amount원';
}

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wishStatsProvider);
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.valueOrNull;
    final isLoggedIn = user != null;
    final nicknameState = ref.watch(nicknameNotifierProvider);
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
              _ProfileCard(
                user: user,
                nicknameState: nicknameState,
                stats: stats,
                onEditNickname: () => _showNicknameEditDialog(context, ref, nicknameState),
                onLoginTap: () => context.go('/login'),
              ),
              const SizedBox(height: 16),
              _GoalAndStatsCard(stats: stats),
              const SizedBox(height: 24),
              _SectionTitle(AppStrings.myLearning, colors: colors),
              const SizedBox(height: 10),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.menu_book_rounded,
                    label: AppStrings.myLearning,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _LearnDetailPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(AppStrings.mySettings, colors: colors),
              const SizedBox(height: 10),
              _NotificationToggleCard(colors: colors),
              const SizedBox(height: 12),
              const _ThemeToggleCard(),
              const SizedBox(height: 24),
              _SectionTitle(AppStrings.myAppInfo, colors: colors),
              const SizedBox(height: 10),
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.myVersion,
                    trailing: '1.0.0',
                    onTap: () {},
                    hideChevron: true,
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: AppStrings.myTerms,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _TermsPage()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: AppStrings.myPrivacy,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _PrivacyPage()),
                    ),
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
                      label: AppStrings.myLogout,
                      labelColor: AppColors.red,
                      onTap: () => _showLogoutDialog(context, ref),
                    )
                  else
                    _SettingsItem(
                      icon: Icons.login_rounded,
                      label: AppStrings.loginGoogleButton,
                      onTap: () => context.go('/login'),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  AppStrings.appFooter,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textTertiary,
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

  void _showNicknameEditDialog(BuildContext context, WidgetRef ref, NicknameState nicknameState) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _NicknameEditDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.myLogout, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
        content: Text(AppStrings.myLogoutConfirmBody, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text(AppStrings.myLogout, style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

// ── 목표 + 통계 통합 카드 ─────────────────────────────────

class _GoalAndStatsCard extends ConsumerWidget {
  const _GoalAndStatsCard({required this.stats});
  final WishStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalNotifierProvider);
    final savedAmount = stats.savedAmount.toInt();
    final colors = context.colors;
    final hasGoal = goals.isNotEmpty;
    final goal = hasGoal ? goals.first : null;
    final progress = (goal != null && goal.targetAmount > 0)
        ? (savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final isReached = progress >= 1.0;

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
          // ── 절약 목표 헤더 ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.mySavingsGoalSection,
                style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              GestureDetector(
                onTap: hasGoal
                    ? () => _showUpdateDialog(context, ref, goal!)
                    : () => _showAddDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(hasGoal ? Icons.edit_rounded : Icons.add_rounded, size: 11, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(hasGoal ? '수정' : '추가', style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── 목표 콘텐츠 ─────────────────────────────────
          if (!hasGoal)
            GestureDetector(
              onTap: () => _showAddDialog(context, ref),
              child: Text('+ 목표를 설정해보세요 🎯', style: TextStyle(fontSize: 13, color: colors.textTertiary)),
            )
          else ...[
            // 목표명 + 달성률
            Row(
              children: [
                Text(goal!.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                if (isReached)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Text(AppStrings.mySavingsGoalReached, style: TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w700)),
                  )
                else
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isReached ? AppColors.green : AppColors.accent)),
              ],
            ),
            const SizedBox(height: 10),
            // 진행 바
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(isReached ? AppColors.green : AppColors.accent),
              ),
            ),
            const SizedBox(height: 10),
            // 절약 / 목표 금액
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_shortAmount(savedAmount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                    Text('절약', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_shortAmount(goal.targetAmount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    Text('목표', style: TextStyle(fontSize: 10, color: colors.textTertiary)),
                  ],
                ),
              ],
            ),
          ],

          // ── 구분선 ──────────────────────────────────────
          const SizedBox(height: 16),
          Divider(color: AppColors.accent.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 14),

          // ── 참음 / 구매 / 등록 통계 행 ─────────────────
          Row(
            children: [
              _SummaryItem(label: AppStrings.myResisted, value: '${stats.cancelledCount}번', color: AppColors.blue),
              _Divider(),
              _SummaryItem(label: AppStrings.myPurchased, value: '${stats.purchasedCount}번', color: AppColors.green),
              _Divider(),
              _SummaryItem(label: AppStrings.myTotalRegistered, value: '${stats.totalCount}개', color: AppColors.accent),
            ],
          ),

        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(context: context, builder: (_) => _AddGoalDialog(onAdd: (goal) => ref.read(savingsGoalNotifierProvider.notifier).add(goal)));
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    showDialog<void>(context: context, builder: (_) => _UpdateGoalDialog(
      goal: goal,
      onUpdate: (updated) => ref.read(savingsGoalNotifierProvider.notifier).update(updated),
      onDelete: () => ref.read(savingsGoalNotifierProvider.notifier).delete(goal.id),
    ));
  }
}

// ── 프로필 히어로 섹션 ─────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.nicknameState,
    required this.stats,
    required this.onEditNickname,
    required this.onLoginTap,
  });

  final UserModel? user;
  final NicknameState nicknameState;
  final WishStats stats;
  final VoidCallback onEditNickname;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (user == null) {
      return GestureDetector(
        onTap: onLoginTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.surfaceHighlight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: colors.inactive, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.loginRequired, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(AppStrings.loginGooglePrompt, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.inactive, size: 20),
            ],
          ),
        ),
      );
    }

    final nickname = nicknameState.nickname.isNotEmpty ? nicknameState.nickname : AppStrings.loading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.gradStart, colors.gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // ── 아바타 (그라디언트 링)
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.yellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: user!.photoUrl != null
                  ? Image.network(
                      user!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _defaultAvatar(colors),
                    )
                  : _defaultAvatar(colors),
            ),
          ),
          const SizedBox(height: 12),
          // ── 닉네임 + 수정 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nicknameState.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                )
              else
                Flexible(
                  child: Text(
                    nickname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEditNickname,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: nicknameState.canChange
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 13,
                      color: nicknameState.canChange ? AppColors.accent : colors.inactive,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // ── 이메일
          Text(
            user!.email,
            style: TextStyle(fontSize: 11, color: colors.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: AppColors.accent.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          // ── 한 줄 스탯
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStat(
                emoji: '🛡',
                value: '${stats.cancelledCount}번',
                label: '참았어요',
                colors: colors,
              ),
              Container(width: 1, height: 32, color: AppColors.accent.withValues(alpha: 0.2)),
              _HeroStat(
                emoji: '🔥',
                value: stats.decidedCount == 0
                    ? '—'
                    : '${(stats.saveRate * 100).toStringAsFixed(0)}%',
                label: '충동구매 저항률',
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar(AppColors colors) {
    return Container(
      color: colors.surfaceHighlight,
      child: Icon(Icons.person_outline, color: colors.inactive, size: 30),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.emoji,
    required this.value,
    required this.label,
    required this.colors,
  });

  final String emoji;
  final String value;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, color: colors.textTertiary)),
      ],
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
    this.hideChevron = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? labelColor;
  final bool hideChevron;

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
            if (labelColor == null && !hideChevron)
              Icon(Icons.chevron_right, size: 18, color: colors.inactive),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleCard extends ConsumerWidget {
  const _NotificationToggleCard({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationSettingsNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
            size: 20,
            color: enabled ? AppColors.accent : colors.textTertiary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppStrings.myNotificationSettings,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeColor: AppColors.accent,
            onChanged: (v) =>
                ref.read(notificationSettingsNotifierProvider.notifier).setEnabled(v),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleCard extends ConsumerWidget {
  const _ThemeToggleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final colors = context.colors;

    final leadingIcon = switch (themeMode) {
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.system => Icons.smartphone_rounded,
    };
    final leadingColor = switch (themeMode) {
      ThemeMode.dark => AppColors.accent,
      ThemeMode.light => AppColors.yellow,
      ThemeMode.system => AppColors.green,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(leadingIcon, size: 20, color: leadingColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(AppStrings.myTheme, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
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
                  icon: Icons.smartphone_rounded,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setSystem(),
                ),
                const SizedBox(width: 4),
                _ThemeSegment(
                  icon: Icons.light_mode_rounded,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeNotifierProvider.notifier).setLight(),
                ),
                const SizedBox(width: 4),
                _ThemeSegment(
                  icon: Icons.dark_mode_rounded,
                  selected: themeMode == ThemeMode.dark,
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

// ── 이용약관 ──────────────────────────────────────────────

class _TermsPage extends StatelessWidget {
  const _TermsPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _PolicyScaffold(
      title: AppStrings.myTerms,
      colors: colors,
      sections: const [
        _PolicySection(title: AppPolicyStrings.terms1Title, body: AppPolicyStrings.terms1Body),
        _PolicySection(title: AppPolicyStrings.terms2Title, body: AppPolicyStrings.terms2Body),
        _PolicySection(title: AppPolicyStrings.terms3Title, body: AppPolicyStrings.terms3Body),
        _PolicySection(title: AppPolicyStrings.terms4Title, body: AppPolicyStrings.terms4Body),
        _PolicySection(title: AppPolicyStrings.terms5Title, body: AppPolicyStrings.terms5Body),
        _PolicySection(title: AppPolicyStrings.terms6Title, body: AppPolicyStrings.terms6Body),
        _PolicySection(title: AppPolicyStrings.terms7Title, body: AppPolicyStrings.terms7Body),
        _PolicySection(title: AppPolicyStrings.termsAdditionalTitle, body: AppPolicyStrings.termsAdditionalBody),
      ],
    );
  }
}

// ── 개인정보 처리방침 ──────────────────────────────────────

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _PolicyScaffold(
      title: AppStrings.myPrivacy,
      colors: colors,
      sections: const [
        _PolicySection(title: AppPolicyStrings.privacy1Title, body: AppPolicyStrings.privacy1Body),
        _PolicySection(title: AppPolicyStrings.privacy2Title, body: AppPolicyStrings.privacy2Body),
        _PolicySection(title: AppPolicyStrings.privacy3Title, body: AppPolicyStrings.privacy3Body),
        _PolicySection(title: AppPolicyStrings.privacy4Title, body: AppPolicyStrings.privacy4Body),
        _PolicySection(title: AppPolicyStrings.privacy5Title, body: AppPolicyStrings.privacy5Body),
        _PolicySection(title: AppPolicyStrings.privacy6Title, body: AppPolicyStrings.privacy6Body),
        _PolicySection(title: AppPolicyStrings.privacy7Title, body: AppPolicyStrings.privacy7Body),
        _PolicySection(title: AppPolicyStrings.privacy8Title, body: AppPolicyStrings.privacy8Body),
      ],
    );
  }
}

// ── 공통 약관 스캐폴드 ────────────────────────────────────

class _PolicyScaffold extends StatelessWidget {
  const _PolicyScaffold({
    required this.title,
    required this.sections,
    required this.colors,
  });

  final String title;
  final List<_PolicySection> sections;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
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
          title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: sections.length,
        separatorBuilder: (context, i) => const SizedBox(height: 20),
        itemBuilder: (_, i) => _PolicySectionWidget(section: sections[i], colors: colors),
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({required this.title, required this.body});
  final String title;
  final String body;
}

class _PolicySectionWidget extends StatelessWidget {
  const _PolicySectionWidget({required this.section, required this.colors});
  final _PolicySection section;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          section.body,
          style: TextStyle(
            fontSize: 13,
            height: 1.7,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── 배움 ─────────────────────────────────────────────────

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
          AppStrings.myLearning,
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

// ── 닉네임 변경 다이얼로그 ─────────────────────────────────

class _NicknameEditDialog extends ConsumerStatefulWidget {
  const _NicknameEditDialog();

  @override
  ConsumerState<_NicknameEditDialog> createState() => _NicknameEditDialogState();
}

class _NicknameEditDialogState extends ConsumerState<_NicknameEditDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nick = _controller.text.trim();
    if (nick.isEmpty) {
      setState(() => _errorMessage = '닉네임을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref.read(nicknameNotifierProvider.notifier).setNickname(nick);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nicknameState = ref.watch(nicknameNotifierProvider);
    final canChange = nicknameState.canChange;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(AppStrings.nicknameChangeTitle, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canChange ? '30일에 한 번 변경할 수 있어요.' : '${nicknameState.daysUntilNextChange}일 후에 변경할 수 있어요.',
            style: TextStyle(
              color: canChange ? colors.textSecondary : AppColors.yellow,
              fontSize: 13,
            ),
          ),
          if (canChange) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 20,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onSubmitted: (_) => _isLoading ? null : _submit(),
              decoration: InputDecoration(
                hintText: AppStrings.nicknameInputHint,
                hintStyle: TextStyle(color: colors.textTertiary),
                errorText: _errorMessage,
                filled: true,
                fillColor: colors.background,
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
        ),
        if (canChange)
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                : const Text(AppStrings.nicknameChangeButton, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}



// ── 저축 목표 추가 다이얼로그 ─────────────────────────────

const _kGoalEmojis = ['🏠', '✈️', '🚗', '📱', '💍', '🎓', '💻', '🌴', '🎯', '💰', '👜', '🏋️'];

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog({required this.onAdd});
  final void Function(SavingsGoal) onAdd;

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedEmoji = '🎯';
  String? _titleError;
  String? _amountError;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amountStr = _amountController.text.trim().replaceAll(',', '');
    final amount = int.tryParse(amountStr);

    setState(() {
      _titleError = title.isEmpty ? AppStrings.mySavingsGoalTitleRequired : null;
      _amountError = (amount == null || amount <= 0) ? AppStrings.mySavingsGoalAmountRequired : null;
    });

    if (_titleError != null || _amountError != null) return;

    final goal = SavingsGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetAmount: amount!,
      emoji: _selectedEmoji,
    );
    widget.onAdd(goal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(AppStrings.mySavingsGoalAddTitle, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji picker
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kGoalEmojis.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent.withValues(alpha: 0.15) : colors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.accent : colors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            // Title field
            TextField(
              controller: _titleController,
              autofocus: true,
              maxLength: 20,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(colors, AppStrings.mySavingsGoalTitleHint, _titleError),
            ),
            const SizedBox(height: 8),
            // Target amount field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onSubmitted: (_) => _submit(),
              decoration: _inputDecoration(colors, AppStrings.mySavingsGoalAmountHint, _amountError,
                  suffix: '원'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(AppStrings.mySavingsGoalAddButton, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(AppColors colors, String hint, String? error, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
      errorText: error,
      suffixText: suffix,
      suffixStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: colors.background,
      counterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

// ── 목표 수정 다이얼로그 ─────────────────────────────────

class _UpdateGoalDialog extends StatefulWidget {
  const _UpdateGoalDialog({
    required this.goal,
    required this.onUpdate,
    required this.onDelete,
  });
  final SavingsGoal goal;
  final void Function(SavingsGoal) onUpdate;
  final VoidCallback onDelete;

  @override
  State<_UpdateGoalDialog> createState() => _UpdateGoalDialogState();
}

class _UpdateGoalDialogState extends State<_UpdateGoalDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedEmoji;
  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _amountController = TextEditingController(text: widget.goal.targetAmount.toString());
    _selectedEmoji = widget.goal.emoji;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    setState(() {
      _titleError = title.isEmpty ? AppStrings.mySavingsGoalTitleRequired : null;
      _amountError = (amount == null || amount <= 0) ? AppStrings.mySavingsGoalAmountRequired : null;
    });

    if (_titleError != null || _amountError != null) return;

    widget.onUpdate(widget.goal.copyWith(
      title: title,
      targetAmount: amount!,
      emoji: _selectedEmoji,
    ));
    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    Navigator.of(context).pop();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(AppStrings.mySavingsGoalEditTitle, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji picker
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kGoalEmojis.map((e) {
                final selected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent.withValues(alpha: 0.15) : colors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.accent : colors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              maxLength: 20,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: _inputDecoration(colors, AppStrings.mySavingsGoalTitleHint, _titleError),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onSubmitted: (_) => _submit(),
              decoration: _inputDecoration(colors, AppStrings.mySavingsGoalAmountHint, _amountError, suffix: '원'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _confirmDelete,
              child: Center(
                child: Text(
                  AppStrings.mySavingsGoalDeleteButton,
                  style: const TextStyle(fontSize: 12, color: AppColors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(AppStrings.mySavingsGoalUpdateButton, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(AppColors colors, String hint, String? error, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
      errorText: error,
      suffixText: suffix,
      suffixStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: colors.background,
      counterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

