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

String _levelBadge(int resistedCount) {
  if (resistedCount >= 50) return '🏆 Lv.5 절약마스터';
  if (resistedCount >= 20) return '💎 Lv.4 절약왕';
  if (resistedCount >= 10) return '🔥 Lv.3 참기고수';
  if (resistedCount >= 5)  return '💪 Lv.2 절약러';
  return '🌱 Lv.1 절약 입문';
}

String _progressFeedback(double progress) {
  if (progress >= 1.0) return '목표 달성! 🏆';
  if (progress >= 0.9) return '마지막 고비예요 ✨';
  if (progress >= 0.6) return '거의 다 왔어요 🔥';
  if (progress >= 0.3) return '잘 하고 있어요 💪';
  if (progress >= 0.1) return '좋은 출발이에요 👍';
  return '아직 시작이에요 🚀';
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
              //_SectionTitle(AppStrings.myLearning, colors: colors),
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
            // 목표명
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
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // 절약 금액 + 원형 퍼센트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 ${_shortAmount(savedAmount)} 아꼈어요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: savedAmount > 0 ? AppColors.green : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '목표 ${_shortAmount(goal.targetAmount)}',
                      style: TextStyle(fontSize: 11, color: colors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(isReached ? AppColors.green : AppColors.accent),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isReached ? AppColors.green : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 진행 바 (gradient)
            Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isReached
                            ? [AppColors.green, const Color(0xFF34D399)]
                            : [AppColors.accent, AppColors.green],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 진행률 피드백 문구
            Text(
              _progressFeedback(progress),
              style: TextStyle(
                fontSize: 12,
                color: isReached ? AppColors.green : AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // ── 구분선 ──────────────────────────────────────
          const SizedBox(height: 16),
          Divider(color: AppColors.accent.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 14),

          // ── 참음 / 구매 / 등록 통계 (스토리형) ─────────
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 13, height: 1.5),
                children: [
                  TextSpan(
                    text: '💪 ${stats.cancelledCount}번 참고',
                    style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '  ·  ',
                    style: TextStyle(color: colors.textTertiary),
                  ),
                  TextSpan(
                    text: '😅 ${stats.purchasedCount}번 사고',
                    style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '  ·  ',
                    style: TextStyle(color: colors.textTertiary),
                  ),
                  TextSpan(
                    text: '📦 ${stats.totalCount}번 도전 중',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
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

    final nickname = nicknameState.nickname.isNotEmpty ? nicknameState.nickname : '';

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
              if (nicknameState.isLoading || !nicknameState.isInitialized)
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
          const SizedBox(height: 10),
          // ── 레벨 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              _levelBadge(stats.cancelledCount),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.accent.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          // ── 성과 스탯
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStat(
                emoji: '🔥',
                value: '${stats.cancelledCount}번',
                label: '참기 성공',
                colors: colors,
              ),
              Container(width: 1, height: 32, color: AppColors.accent.withValues(alpha: 0.2)),
              _HeroStat(
                emoji: '💰',
                value: stats.savedAmount > 0 ? _shortAmount(stats.savedAmount.toInt()) : '—',
                label: '충동구매 방어',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.myNotificationSettings,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
                Text(
                  AppStrings.myNotificationSubtitle,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
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
const _kGoalSuggestions = ['내집마련', '여행', '차 구매', '노트북', '결혼'];

InputDecoration _goalInputDecoration(AppColors colors, String hint, String? error, {String? prefix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.textTertiary, fontSize: 13),
    errorText: error,
    prefixText: prefix,
    prefixStyle: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
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

String _commaFormat(int n) {
  if (n <= 0) return '';
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

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

  void _addAmount(int delta) {
    final current = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final updated = current + delta;
    _amountController.text = _commaFormat(updated);
    _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
    setState(() => _amountError = null);
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    setState(() {
      _titleError = title.isEmpty ? AppStrings.mySavingsGoalTitleRequired : null;
      _amountError = (amount == null || amount <= 0) ? AppStrings.mySavingsGoalAmountRequired : null;
    });
    if (_titleError != null || _amountError != null) return;
    widget.onAdd(SavingsGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetAmount: amount!,
      emoji: _selectedEmoji,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amountVal = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: Text(
        '어떤 목표를 위해 참을까요?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.3),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GoalEmojiPicker(
              selected: _selectedEmoji,
              onSelect: (e) => setState(() => _selectedEmoji = e),
              colors: colors,
            ),
            const SizedBox(height: 10),
            _GoalSuggestionChips(
              onSelect: (s) {
                _titleController.text = s;
                setState(() => _titleError = null);
              },
              colors: colors,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              autofocus: true,
              maxLength: 20,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onChanged: (_) { if (_titleError != null) setState(() => _titleError = null); },
              decoration: _goalInputDecoration(colors, '예: 내집마련, 여행가기, 아이폰 구매', _titleError),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GoalAmountFormatter()],
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
                setState(() {});
              },
              onSubmitted: (_) => _submit(),
              decoration: _goalInputDecoration(colors, '목표 금액', _amountError, prefix: '₩ '),
            ),
            const SizedBox(height: 8),
            _QuickAmountChips(onAdd: _addAmount, colors: colors),
            if (amountVal > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '이 목표를 위해 소비를 줄여보세요 💪',
                  style: TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w500),
                ),
              ),
            ],
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
          child: const Text('목표 설정하기', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ),
      ],
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
    _amountController = TextEditingController(text: _commaFormat(widget.goal.targetAmount));
    _selectedEmoji = widget.goal.emoji;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addAmount(int delta) {
    final current = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final updated = current + delta;
    _amountController.text = _commaFormat(updated);
    _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
    setState(() => _amountError = null);
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    setState(() {
      _titleError = title.isEmpty ? AppStrings.mySavingsGoalTitleRequired : null;
      _amountError = (amount == null || amount <= 0) ? AppStrings.mySavingsGoalAmountRequired : null;
    });
    if (_titleError != null || _amountError != null) return;
    widget.onUpdate(widget.goal.copyWith(title: title, targetAmount: amount!, emoji: _selectedEmoji));
    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    Navigator.of(context).pop();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amountVal = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: Text(
        '목표를 수정할까요?',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GoalEmojiPicker(
              selected: _selectedEmoji,
              onSelect: (e) => setState(() => _selectedEmoji = e),
              colors: colors,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              maxLength: 20,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onChanged: (_) { if (_titleError != null) setState(() => _titleError = null); },
              decoration: _goalInputDecoration(colors, '예: 내집마련, 여행가기', _titleError),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _GoalAmountFormatter()],
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              onChanged: (_) {
                if (_amountError != null) setState(() => _amountError = null);
                setState(() {});
              },
              onSubmitted: (_) => _submit(),
              decoration: _goalInputDecoration(colors, '목표 금액', _amountError, prefix: '₩ '),
            ),
            const SizedBox(height: 8),
            _QuickAmountChips(onAdd: _addAmount, colors: colors),
            if (amountVal > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '이 목표를 위해 소비를 줄여보세요 💪',
                  style: TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // 삭제 (하단, 약하게)
            GestureDetector(
              onTap: _confirmDelete,
              child: Center(
                child: Text(
                  AppStrings.mySavingsGoalDeleteButton,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary, decoration: TextDecoration.underline),
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
          child: const Text('목표 업데이트', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ── 목표 설정 공유 헬퍼 위젯 ──────────────────────────────

class _GoalEmojiPicker extends StatelessWidget {
  const _GoalEmojiPicker({required this.selected, required this.onSelect, required this.colors});
  final String selected;
  final ValueChanged<String> onSelect;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _kGoalEmojis.map((e) {
        final isSelected = e == selected;
        return GestureDetector(
          onTap: () => onSelect(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isSelected ? 44 : 40,
            height: isSelected ? 44 : 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.18)
                  : colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.accent : colors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Center(
              child: Text(e, style: TextStyle(fontSize: isSelected ? 22 : 18)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GoalSuggestionChips extends StatelessWidget {
  const _GoalSuggestionChips({required this.onSelect, required this.colors});
  final ValueChanged<String> onSelect;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: _kGoalSuggestions.map((s) {
        return GestureDetector(
          onTap: () => onSelect(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Text(s, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAmountChips extends StatelessWidget {
  const _QuickAmountChips({required this.onAdd, required this.colors});
  final ValueChanged<int> onAdd;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AmountChip(label: '+100만', amount: 1000000, onAdd: onAdd),
        const SizedBox(width: 6),
        _AmountChip(label: '+500만', amount: 5000000, onAdd: onAdd),
        const SizedBox(width: 6),
        _AmountChip(label: '+1000만', amount: 10000000, onAdd: onAdd),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.amount, required this.onAdd});
  final String label;
  final int amount;
  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onAdd(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GoalAmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(',', '');
    if (digits.isEmpty) return newVal.copyWith(text: '');
    final n = int.tryParse(digits);
    if (n == null) return old;
    final formatted = _commaFormat(n);
    return newVal.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

