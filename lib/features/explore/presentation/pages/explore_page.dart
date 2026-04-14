import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/ads/ad_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/my/presentation/providers/nickname_provider.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/models/community_post.dart';
import '../providers/community_provider.dart';

// ── 공유 위젯: 마이 탭 배움 섹션에서도 사용 ──────────────

class ExploreContent extends StatelessWidget {
  const ExploreContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuoteCard(colors: colors),
        const SizedBox(height: 16),
        _SectionLabel(AppStrings.sectionConsumptionTips, colors: colors),
        const SizedBox(height: 10),
        ..._consumptionTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip, colors: colors),
            )),
        const SizedBox(height: 6),
        _SectionLabel(AppStrings.sectionMinimalism, colors: colors),
        const SizedBox(height: 10),
        ..._minimalismTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip, colors: colors),
            )),
        const SizedBox(height: 6),
        _SectionLabel(AppStrings.section72hRule, colors: colors),
        const SizedBox(height: 10),
        ..._ruleTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip, colors: colors),
            )),
      ],
    );
  }
}

// ── 커뮤니티 페이지 ──────────────────────────────────────

enum _PostFilter { all, review, tip }
enum _PostSort { recent, popular }
enum _AdSlot { banner, native }

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  _PostFilter _filter = _PostFilter.all;
  _PostSort _sort = _PostSort.recent;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadNativeAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConfig.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (_) => setState(() => _isNativeAdLoaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  // 배너: 2번째 카드 뒤, 네이티브: 이후 5개마다 삽입
  List<Object> _buildMixedList(List<CommunityPost> posts) {
    final List<Object> mixed = [];
    for (int i = 0; i < posts.length; i++) {
      mixed.add(posts[i]);
      if (i == 1 && _isBannerLoaded) {
        mixed.add(_AdSlot.banner);
      } else if (i > 1 && (i + 1) % 5 == 0 && _isNativeAdLoaded) {
        mixed.add(_AdSlot.native);
      }
    }
    return mixed;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final postsAsync = ref.watch(communityPostsProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: _WriteFab(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _WritePostSheet(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterRow(selected: _filter, onChanged: (f) => setState(() => _filter = f)),
            _SortRow(selected: _sort, onChanged: (s) => setState(() => _sort = s)),
            Expanded(
              child: postsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Text(AppStrings.exploreLoadError, style: TextStyle(color: context.colors.textSecondary)),
                ),
                data: (posts) {
                  var filtered = _filter == _PostFilter.all
                      ? posts
                      : posts.where((p) {
                          return _filter == _PostFilter.review
                              ? p.type == PostType.review
                              : p.type == PostType.tip;
                        }).toList();

                  if (_sort == _PostSort.popular) {
                    filtered = List.of(filtered)
                      ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.exploreEmptyPosts,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: colors.textTertiary, height: 1.7),
                      ),
                    );
                  }

                  final mixedItems = _buildMixedList(filtered);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: mixedItems.length + 1, // +1 for banner
                    itemBuilder: (_, i) {
                      // 첫 번째 아이템: 동기부여 배너
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MotivationBanner(posts: posts),
                        );
                      }
                      final item = mixedItems[i - 1];
                      if (item == _AdSlot.banner) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        );
                      }
                      if (item == _AdSlot.native) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(height: 320, child: AdWidget(ad: _nativeAd!)),
                        );
                      }
                      final post = item as CommunityPost;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PostCard(
                          post: post,
                          currentUid: currentUid,
                          onLike: currentUid == null
                              ? null
                              : () => ref
                                  .read(communityRepositoryProvider)
                                  .toggleLike(post.id, currentUid),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteFab extends StatelessWidget {
  const _WriteFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final fabColors = isDark
        ? [AppColors.green, const Color(0xFF28A372)]
        : [AppColors.accent, const Color(0xFF2D6FD4)];
    final shadowColor = isDark ? AppColors.green : AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: fabColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              AppStrings.exploreFabLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.selected, required this.onChanged});
  final _PostSort selected;
  final ValueChanged<_PostSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          _SortChip(
            label: AppStrings.exploreSortRecent,
            icon: Icons.access_time_rounded,
            selected: selected == _PostSort.recent,
            onTap: () => onChanged(_PostSort.recent),
            colors: colors,
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: AppStrings.exploreSortPopular,
            icon: Icons.local_fire_department_rounded,
            selected: selected == _PostSort.popular,
            onTap: () => onChanged(_PostSort.popular),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? AppColors.accent : colors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.accent : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});
  final _PostFilter selected;
  final ValueChanged<_PostFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = <({_PostFilter filter, String label, IconData icon, Color color})>[
      (filter: _PostFilter.all,    label: AppStrings.exploreFilterAll,    icon: Icons.grid_view_rounded,         color: AppColors.accent),
      (filter: _PostFilter.review, label: AppStrings.exploreFilterReview, icon: Icons.rate_review_outlined,      color: AppColors.yellow),
      (filter: _PostFilter.tip,    label: AppStrings.exploreFilterTip,    icon: Icons.lightbulb_outline_rounded, color: AppColors.green),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: items.map((e) {
          final isSelected = selected == e.filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? e.color : colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? e.color : colors.border,
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: e.color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.icon, size: 15, color: isSelected ? Colors.white : colors.textSecondary),
                    const SizedBox(height: 3),
                    Text(
                      e.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? Colors.white : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 동기부여 배너 ──────────────────────────────────────────

class _MotivationBanner extends StatelessWidget {
  const _MotivationBanner({required this.posts});
  final List<CommunityPost> posts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayResisted = posts
        .where((p) => p.type == PostType.review && p.resisted && p.createdAt.isAfter(todayStart))
        .length;
    final totalReviews = posts.where((p) => p.type == PostType.review).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: context.isDark ? 0.18 : 0.08),
            AppColors.green.withValues(alpha: context.isDark ? 0.14 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                emoji: '🔥',
                value: todayResisted,
                unit: '명',
                label: '오늘 참기 성공',
                colors: colors,
              ),
            ),
            VerticalDivider(width: 1, color: colors.border),
            Expanded(
              child: _StatItem(
                emoji: '💬',
                value: totalReviews,
                unit: '개',
                label: '실전 후기',
                colors: colors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.emoji,
    required this.value,
    required this.unit,
    required this.label,
    required this.colors,
  });
  final String emoji;
  final int value;
  final String unit;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({
    required this.post,
    required this.currentUid,
    required this.onLike,
  });
  final CommunityPost post;
  final String? currentUid;
  final VoidCallback? onLike;

  Color _avatarColor(String uid) {
    const palette = [
      AppColors.accent,
      AppColors.green,
      AppColors.blue,
      AppColors.yellow,
      Color(0xFF2DD4BF), // teal
      Color(0xFFA78BFA), // lavender
    ];
    return palette[uid.codeUnits.fold(0, (a, b) => a + b) % palette.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isReview = post.type == PostType.review;
    final isLiked = currentUid != null && post.isLikedBy(currentUid!);
    final avatarColor = _avatarColor(post.uid);
    final nicknameAsync = ref.watch(authorNicknameProvider(post.uid));
    final displayNickname = nicknameAsync.valueOrNull?.isNotEmpty == true
        ? nicknameAsync.value!
        : post.nickname;

    final accentColor = isReview ? const Color(0xFFD97706) : AppColors.green;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PostDetailPage(
            post: post,
            currentUid: currentUid,
            onLike: onLike,
            displayNickname: displayNickname,
            avatarColor: avatarColor,
          ),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.5),
          child: ColoredBox(
            color: colors.surface,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(width: 3, color: accentColor),
                  // Card content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: avatar + nickname + badge
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: avatarColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Center(
                                  child: Text(
                                    displayNickname.isNotEmpty ? displayNickname[0] : '?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: avatarColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayNickname,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      post.relativeDate,
                                      style: TextStyle(fontSize: 11, color: colors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isReview ? '📖 후기' : '💡 팁',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              if (currentUid == post.uid) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => _EditPostSheet(post: post),
                                  ),
                                  child: Icon(Icons.edit_outlined, size: 16, color: colors.textTertiary),
                                ),
                              ],
                            ],
                          ),
                          // Item name chip
                          if (post.itemName != null && post.itemName!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 13, color: colors.textTertiary),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppStrings.exploreResistStatus(post.resisted, post.itemName ?? ''),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: post.resisted ? AppColors.blue : colors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Content
                          const SizedBox(height: 10),
                          Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, height: 1.6, color: colors.textPrimary),
                          ),
                          // Like button
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: onLike,
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    key: ValueKey(isLiked),
                                    size: 16,
                                    color: isLiked ? AppColors.red : colors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  AppStrings.exploreLikeLabel(post.likesCount),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isLiked ? FontWeight.w600 : FontWeight.w400,
                                    color: isLiked ? AppColors.red : colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 게시글 상세 페이지 ─────────────────────────────────────

class _PostDetailPage extends ConsumerWidget {
  const _PostDetailPage({
    required this.post,
    required this.currentUid,
    required this.onLike,
    required this.displayNickname,
    required this.avatarColor,
  });
  final CommunityPost post;
  final String? currentUid;
  final VoidCallback? onLike;
  final String displayNickname;
  final Color avatarColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isReview = post.type == PostType.review;
    final isLiked = currentUid != null && post.isLikedBy(currentUid!);

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
          isReview ? '후기' : '팁',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        actions: [
          if (currentUid == post.uid)
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: colors.textSecondary),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _EditPostSheet(
                  post: post,
                  onSuccess: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      displayNickname.isNotEmpty ? displayNickname[0] : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayNickname,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        post.relativeDate,
                        style: TextStyle(fontSize: 12, color: colors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReview
                        ? AppColors.green.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isReview ? AppStrings.exploreFilterReview : AppStrings.exploreFilterTip,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isReview ? AppColors.green : AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            if (post.itemName != null && post.itemName!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: colors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.exploreResistStatus(post.resisted, post.itemName ?? ''),
                      style: TextStyle(
                        fontSize: 13,
                        color: post.resisted ? AppColors.blue : colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              post.content,
              style: TextStyle(fontSize: 15, height: 1.8, color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onLike,
              child: Row(
                children: [
                  Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: isLiked ? AppColors.red : colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likesCount}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isLiked ? AppColors.red : colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 글쓰기 바텀시트 ───────────────────────────────────────

class _WritePostSheet extends ConsumerStatefulWidget {
  const _WritePostSheet();

  @override
  ConsumerState<_WritePostSheet> createState() => _WritePostSheetState();
}

class _WritePostSheetState extends ConsumerState<_WritePostSheet> {
  PostType _type = PostType.review;
  final _itemController = TextEditingController();
  final _contentController = TextEditingController();
  bool _resisted = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _itemController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty && !_isSubmitting;

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginRequiredSnackbar)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final nicknameState = ref.read(nicknameNotifierProvider);
      final post = CommunityPost(
        id: '',
        uid: user.uid,
        nickname: nicknameState.nickname.isNotEmpty ? nicknameState.nickname : (user.displayName ?? AppStrings.anonymous),
        type: _type,
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
        likesCount: 0,
        likedBy: const [],
        itemName: _type == PostType.review && _itemController.text.trim().isNotEmpty
            ? _itemController.text.trim()
            : null,
        resisted: _resisted,
      );
      await ref.read(communityRepositoryProvider).addPost(post);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.exploreSubmitError(e))),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.exploreWriteSheetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // 유형 선택
            Row(
              children: [
                _TypeChip(
                  label: AppStrings.exploreFilterReview,
                  icon: Icons.rate_review_outlined,
                  selected: _type == PostType.review,
                  color: AppColors.green,
                  onTap: () => setState(() => _type = PostType.review),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: AppStrings.exploreFilterTip,
                  icon: Icons.lightbulb_outline_rounded,
                  selected: _type == PostType.tip,
                  color: AppColors.accent,
                  onTap: () => setState(() => _type = PostType.tip),
                ),
              ],
            ),
            if (_type == PostType.review) ...[
              const SizedBox(height: 16),
              _SheetField(
                controller: _itemController,
                hint: AppStrings.exploreItemNameHint,
                colors: colors,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _TypeChip(
                    label: AppStrings.exploreResisted,
                    icon: Icons.self_improvement_rounded,
                    selected: _resisted,
                    color: AppColors.blue,
                    onTap: () => setState(() => _resisted = true),
                  ),
                  const SizedBox(width: 10),
                  _TypeChip(
                    label: AppStrings.explorePurchased,
                    icon: Icons.shopping_bag_outlined,
                    selected: !_resisted,
                    color: AppColors.green,
                    onTap: () => setState(() => _resisted = false),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _SheetField(
              controller: _contentController,
              hint: _type == PostType.review
                  ? AppStrings.exploreReviewHint
                  : AppStrings.exploreTipHint,
              colors: colors,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _canSubmit ? _submit : null,
              child: AnimatedOpacity(
                opacity: _canSubmit ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D8FE8), Color(0xFF2D6FD4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            AppStrings.explorePostSubmitButton,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 글수정 바텀시트 ───────────────────────────────────────

class _EditPostSheet extends ConsumerStatefulWidget {
  const _EditPostSheet({required this.post, this.onSuccess});
  final CommunityPost post;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends ConsumerState<_EditPostSheet> {
  late PostType _type;
  late final TextEditingController _itemController;
  late final TextEditingController _contentController;
  late bool _resisted;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _type = widget.post.type;
    _itemController = TextEditingController(text: widget.post.itemName ?? '');
    _contentController = TextEditingController(text: widget.post.content);
    _resisted = widget.post.resisted;
  }

  @override
  void dispose() {
    _itemController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _contentController.text.trim().isNotEmpty && !_isSubmitting;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(communityRepositoryProvider).updatePost(
        widget.post.id,
        type: _type,
        content: _contentController.text.trim(),
        itemName: _type == PostType.review && _itemController.text.trim().isNotEmpty
            ? _itemController.text.trim()
            : null,
        resisted: _resisted,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.exploreEditError(e))),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.exploreEditSheetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TypeChip(
                  label: AppStrings.exploreFilterReview,
                  icon: Icons.rate_review_outlined,
                  selected: _type == PostType.review,
                  color: AppColors.green,
                  onTap: () => setState(() => _type = PostType.review),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: AppStrings.exploreFilterTip,
                  icon: Icons.lightbulb_outline_rounded,
                  selected: _type == PostType.tip,
                  color: AppColors.accent,
                  onTap: () => setState(() => _type = PostType.tip),
                ),
              ],
            ),
            if (_type == PostType.review) ...[
              const SizedBox(height: 16),
              _SheetField(
                controller: _itemController,
                hint: AppStrings.exploreItemNameHint,
                colors: colors,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _TypeChip(
                    label: AppStrings.exploreResisted,
                    icon: Icons.self_improvement_rounded,
                    selected: _resisted,
                    color: AppColors.blue,
                    onTap: () => setState(() => _resisted = true),
                  ),
                  const SizedBox(width: 10),
                  _TypeChip(
                    label: AppStrings.explorePurchased,
                    icon: Icons.shopping_bag_outlined,
                    selected: !_resisted,
                    color: AppColors.green,
                    onTap: () => setState(() => _resisted = false),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _SheetField(
              controller: _contentController,
              hint: _type == PostType.review
                  ? AppStrings.exploreReviewHint
                  : AppStrings.exploreTipHint,
              colors: colors,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _canSubmit ? _submit : null,
              child: AnimatedOpacity(
                opacity: _canSubmit ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D8FE8), Color(0xFF2D6FD4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            AppStrings.exploreEditSubmitButton,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    required this.colors,
    this.maxLines = 1,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final AppColors colors;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(color: colors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.inactive),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── 배움 섹션 위젯 ────────────────────────────────────────

const _quote = (
  text: AppStrings.learnQuoteText,
  author: AppStrings.learnQuoteAuthor,
);

const _consumptionTips = [
  (
    icon: Icons.shopping_cart_outlined,
    color: AppColors.accent,
    title: AppStrings.tip1Title,
    body: AppStrings.tip1Body,
  ),
  (
    icon: Icons.receipt_long_outlined,
    color: AppColors.green,
    title: AppStrings.tip2Title,
    body: AppStrings.tip2Body,
  ),
  (
    icon: Icons.compare_arrows_rounded,
    color: AppColors.yellow,
    title: AppStrings.tip3Title,
    body: AppStrings.tip3Body,
  ),
];

const _minimalismTips = [
  (
    icon: Icons.home_outlined,
    color: Color(0xFF60A5FA),
    title: AppStrings.minimal1Title,
    body: AppStrings.minimal1Body,
  ),
  (
    icon: Icons.star_outline_rounded,
    color: AppColors.accent,
    title: AppStrings.minimal2Title,
    body: AppStrings.minimal2Body,
  ),
];

const _ruleTips = [
  (
    icon: Icons.timer_outlined,
    color: AppColors.accent,
    title: AppStrings.rule1Title,
    body: AppStrings.rule1Body,
  ),
  (
    icon: Icons.psychology_outlined,
    color: AppColors.green,
    title: AppStrings.rule2Title,
    body: AppStrings.rule2Body,
  ),
  (
    icon: Icons.trending_up_rounded,
    color: AppColors.yellow,
    title: AppStrings.rule3Title,
    body: AppStrings.rule3Body,
  ),
];

// ── 공통 위젯 ──────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: AppColors.accent, size: 28),
          const SizedBox(height: 10),
          Text(
            _quote.text,
            style: TextStyle(fontSize: 14, height: 1.7, color: colors.textPrimary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(_quote.author, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.colors});
  final String title;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textTertiary, letterSpacing: 0.4),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.colors});
  final ({IconData icon, Color color, String title, String body}) tip;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tip.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, size: 20, color: tip.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 6),
                Text(tip.body, style: TextStyle(fontSize: 13, height: 1.6, color: colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? color : colors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

