import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/explore/presentation/pages/explore_page.dart';
import '../../../../features/home/domain/models/wish_stats.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';
import '../providers/nickname_provider.dart';

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
                onEditNickname: () => _showNicknameEditDialog(context, ref, nicknameState),
                onLoginTap: () => context.go('/login'),
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
                    hideChevron: true,
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: '이용약관',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const _TermsPage()),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보 처리방침',
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

  void _showNicknameEditDialog(BuildContext context, WidgetRef ref, NicknameState nicknameState) {
    if (!nicknameState.canChange) return;
    final controller = TextEditingController();
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (ctx) => _NicknameEditDialog(
        controller: controller,
        colors: colors,
        onConfirm: (nick) async {
          return ref.read(nicknameNotifierProvider.notifier).setNickname(nick);
        },
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

// ── 프로필 카드 ───────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.nicknameState,
    required this.onEditNickname,
    required this.onLoginTap,
  });

  final UserModel? user;
  final NicknameState nicknameState;
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surfaceHighlight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: colors.inactive, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('로그인이 필요해요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Google 로그인으로 데이터를 보관하세요', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.inactive, size: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.gradStart, colors.gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: user!.photoUrl != null
                  ? Image.network(
                      user!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _defaultAvatarContent(colors),
                    )
                  : _defaultAvatarContent(colors),
            ),
          ),
          const SizedBox(width: 14),
          // 닉네임 + 이메일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nicknameState.nickname.isNotEmpty ? nicknameState.nickname : '로딩 중...',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (nicknameState.isLoading)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                      )
                    else if (nicknameState.canChange)
                      GestureDetector(
                        onTap: onEditNickname,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.edit_rounded, size: 12, color: AppColors.accent),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user!.email,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (nicknameState.canChange) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diversity_3_rounded, size: 11, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '닉네임 1회 변경 가능',
                          style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatarContent(AppColors colors) {
    return Container(
      color: colors.surfaceHighlight,
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

// ── 이용약관 ──────────────────────────────────────────────

class _TermsPage extends StatelessWidget {
  const _TermsPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _PolicyScaffold(
      title: '이용약관',
      colors: colors,
      sections: const [
        _PolicySection(
          title: '제1조 (목적)',
          body: '본 약관은 지름막(이하 "앱")이 제공하는 서비스의 이용과 관련하여 앱과 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
        ),
        _PolicySection(
          title: '제2조 (서비스 이용)',
          body: '① 앱은 충동구매를 방지하기 위한 72시간 대기 기능, 소비 기록 관리, 커뮤니티 나눔 기능을 제공합니다.\n② 서비스는 Google 계정을 통한 로그인 후 이용 가능하며, 일부 기능은 비로그인 상태에서도 사용할 수 있습니다.\n③ 이용자는 앱의 서비스를 개인적, 비상업적 목적으로만 이용할 수 있습니다.',
        ),
        _PolicySection(
          title: '제3조 (이용자의 의무)',
          body: '① 이용자는 다음 행위를 해서는 안 됩니다.\n  - 타인의 정보를 도용하거나 허위 정보를 등록하는 행위\n  - 앱의 운영을 방해하거나 서버에 과부하를 유발하는 행위\n  - 커뮤니티에 욕설, 비방, 광고 등 부적절한 게시물을 작성하는 행위\n  - 관련 법령에 위반되는 행위\n② 이용자는 본 약관 및 관련 법령을 준수할 의무가 있습니다.',
        ),
        _PolicySection(
          title: '제4조 (서비스 중단)',
          body: '앱은 다음의 경우 서비스 제공을 일시적으로 중단할 수 있습니다.\n  - 서버 점검, 교체, 고장, 통신두절 등의 경우\n  - 천재지변, 국가비상사태 등 불가항력적인 경우\n  - 기타 앱이 서비스 제공이 불가능하다고 판단하는 경우',
        ),
        _PolicySection(
          title: '제5조 (광고)',
          body: '앱은 Google AdMob을 통한 광고를 제공할 수 있으며, 광고 수익은 서비스 운영 및 개선에 사용됩니다. 광고는 관련 법령에 따라 표시됩니다.',
        ),
        _PolicySection(
          title: '제6조 (면책조항)',
          body: '① 앱은 이용자가 서비스를 통해 기대하는 수익이나 소비 절약 효과에 대해 보증하지 않습니다.\n② 이용자 간 커뮤니티 나눔 게시물의 내용에 대해 앱은 책임을 지지 않습니다.\n③ 앱은 무료로 제공되는 서비스의 중단으로 인한 손해에 대해 책임을 지지 않습니다.',
        ),
        _PolicySection(
          title: '제7조 (약관의 변경)',
          body: '앱은 필요한 경우 약관을 변경할 수 있으며, 변경된 약관은 앱 내 공지를 통해 이용자에게 알립니다. 변경된 약관에 동의하지 않는 경우 서비스 이용을 중단하고 탈퇴할 수 있습니다.',
        ),
        _PolicySection(
          title: '부칙',
          body: '본 약관은 2025년 1월 1일부터 시행됩니다.',
        ),
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
      title: '개인정보 처리방침',
      colors: colors,
      sections: const [
        _PolicySection(
          title: '1. 수집하는 개인정보',
          body: '앱은 서비스 제공을 위해 다음과 같은 정보를 수집합니다.\n\n[필수 수집 항목]\n  - Google 계정 이메일, 프로필 사진 (로그인 시)\n  - 사용자가 입력한 참기 아이템 이름, 가격, 이유\n\n[자동 수집 항목]\n  - 기기 정보 (광고 제공 목적, Google AdMob)\n  - 앱 이용 기록',
        ),
        _PolicySection(
          title: '2. 개인정보의 수집 목적',
          body: '수집한 개인정보는 다음 목적으로만 사용됩니다.\n  - 회원 식별 및 서비스 제공\n  - 소비 기록 저장 및 통계 제공\n  - 커뮤니티 나눔 서비스 운영\n  - 맞춤형 광고 제공 (Google AdMob)',
        ),
        _PolicySection(
          title: '3. 개인정보의 보유 및 이용기간',
          body: '수집한 개인정보는 서비스 이용 기간 동안 보유하며, 회원 탈퇴 시 즉시 삭제합니다. 단, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관합니다.',
        ),
        _PolicySection(
          title: '4. 개인정보의 제3자 제공',
          body: '앱은 이용자의 개인정보를 원칙적으로 제3자에게 제공하지 않습니다. 다만, 다음의 경우는 예외입니다.\n  - 이용자가 사전에 동의한 경우\n  - 법령에 따라 수사기관의 요청이 있는 경우\n  - Google AdMob을 통한 광고 서비스 제공 (기기 식별 정보에 한함)',
        ),
        _PolicySection(
          title: '5. 개인정보 처리 위탁',
          body: '앱은 서비스 운영을 위해 다음 업체에 개인정보 처리를 위탁합니다.\n\n  - Google Firebase (데이터 저장 및 인증)\n    위탁 목적: 회원 인증, 데이터 저장\n\n  - Google AdMob (광고 서비스)\n    위탁 목적: 광고 제공 및 분석',
        ),
        _PolicySection(
          title: '6. 이용자의 권리',
          body: '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.\n  - 개인정보 열람 요청\n  - 개인정보 수정 요청\n  - 개인정보 삭제 요청 (회원 탈퇴)\n  - 개인정보 처리 정지 요청\n\n위 권리 행사는 앱 내 설정 또는 이메일을 통해 요청하실 수 있습니다.',
        ),
        _PolicySection(
          title: '7. 개인정보 보호책임자',
          body: '개인정보 처리에 관한 문의는 앱 내 이메일을 통해 연락해 주시기 바랍니다. 이용자의 문의에 성실히 답변하겠습니다.',
        ),
        _PolicySection(
          title: '8. 방침의 변경',
          body: '본 개인정보 처리방침은 법령, 정책 변경에 따라 수정될 수 있으며 변경 시 앱 내 공지를 통해 안내합니다.\n\n시행일: 2025년 1월 1일',
        ),
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

// ── 닉네임 변경 다이얼로그 ─────────────────────────────────

class _NicknameEditDialog extends StatefulWidget {
  const _NicknameEditDialog({
    required this.controller,
    required this.colors,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final AppColors colors;
  final Future<String?> Function(String) onConfirm;

  @override
  State<_NicknameEditDialog> createState() => _NicknameEditDialogState();
}

class _NicknameEditDialogState extends State<_NicknameEditDialog> {
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _submit() async {
    final nick = widget.controller.text.trim();
    if (nick.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await widget.onConfirm(nick);

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
    final colors = widget.colors;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('닉네임 변경', style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '닉네임은 한 번만 변경할 수 있어요.',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.controller,
            autofocus: true,
            maxLength: 20,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '새 닉네임 입력',
              hintStyle: TextStyle(color: colors.textTertiary),
              errorText: _errorMessage,
              filled: true,
              fillColor: colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                )
              : const Text('변경', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

