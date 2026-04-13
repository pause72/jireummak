import 'package:flutter/material.dart';
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
              _SettingsGroup(
                colors: colors,
                items: [
                  _SettingsItem(
                    icon: Icons.notifications_none_rounded,
                    label: AppStrings.myNotificationSettings,
                    onTap: () {},
                  ),
                ],
              ),
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
                  AppStrings.myTotalSaved,
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
                _SummaryItem(label: AppStrings.myResisted, value: '${stats.cancelledCount}번', color: AppColors.blue),
                _Divider(),
                _SummaryItem(label: AppStrings.myPurchased, value: '${stats.purchasedCount}번', color: AppColors.green),
                _Divider(),
                _SummaryItem(label: AppStrings.myTotalRegistered, value: '${stats.totalCount}개', color: AppColors.accent),
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
                    AppStrings.myResistanceRate,
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
                        nicknameState.nickname.isNotEmpty ? nicknameState.nickname : AppStrings.loading,
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
                          AppStrings.myNicknameHint,
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
      title: Text(AppStrings.nicknameChangeTitle, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.nicknameChangeWarning,
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
              hintText: AppStrings.nicknameInputHint,
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
          child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                )
              : const Text(AppStrings.nicknameChangeButton, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

