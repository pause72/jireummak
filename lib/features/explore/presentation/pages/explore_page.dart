import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
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
        _SectionLabel('소비 습관 팁', colors: colors),
        const SizedBox(height: 10),
        ..._consumptionTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip, colors: colors),
            )),
        const SizedBox(height: 6),
        _SectionLabel('미니멀리즘', colors: colors),
        const SizedBox(height: 10),
        ..._minimalismTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip, colors: colors),
            )),
        const SizedBox(height: 6),
        _SectionLabel('72시간 룰', colors: colors),
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

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  _PostFilter _filter = _PostFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final postsAsync = ref.watch(communityPostsProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const _WritePostPage()),
        ),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _FilterRow(selected: _filter, onChanged: (f) => setState(() => _filter = f)),
            const SizedBox(height: 4),
            Expanded(
              child: postsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Text('불러오기 실패', style: TextStyle(color: context.colors.textSecondary)),
                ),
                data: (posts) {
                  final filtered = _filter == _PostFilter.all
                      ? posts
                      : posts.where((p) {
                          return _filter == _PostFilter.review
                              ? p.type == PostType.review
                              : p.type == PostType.tip;
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        '아직 게시글이 없어요\n첫 번째 나눔을 남겨보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: colors.textTertiary, height: 1.7),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _PostCard(
                      post: filtered[i],
                      currentUid: currentUid,
                      onLike: currentUid == null
                          ? null
                          : () => ref
                              .read(communityRepositoryProvider)
                              .toggleLike(filtered[i].id, currentUid),
                    ),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});
  final _PostFilter selected;
  final ValueChanged<_PostFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = [
      (_PostFilter.all,    '전체'),
      (_PostFilter.review, '후기'),
      (_PostFilter.tip,    '팁'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: items.map((e) {
          final isSelected = selected == e.$1;
          return GestureDetector(
            onTap: () => onChanged(e.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.accent : colors.border,
                ),
              ),
              child: Text(
                e.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.currentUid,
    required this.onLike,
  });
  final CommunityPost post;
  final String? currentUid;
  final VoidCallback? onLike;

  Color _avatarColor(String uid) {
    final colors = [
      AppColors.accent,
      AppColors.green,
      AppColors.blue,
      AppColors.yellow,
      AppColors.red,
      const Color(0xFF2DD4BF),
    ];
    return colors[uid.codeUnits.fold(0, (a, b) => a + b) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isReview = post.type == PostType.review;
    final isLiked = currentUid != null && post.isLikedBy(currentUid!);
    final avatarColor = _avatarColor(post.uid);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    post.nickname.isNotEmpty ? post.nickname[0] : '?',
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
                      post.nickname,
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
                  color: isReview
                      ? AppColors.green.withValues(alpha: 0.12)
                      : AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isReview ? '후기' : '팁',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReview ? AppColors.green : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
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
                    '72시간 후 ${post.resisted ? "참았어요" : "샀어요"} — ${post.itemName}',
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
          const SizedBox(height: 10),
          Text(
            post.content,
            style: TextStyle(fontSize: 14, height: 1.6, color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16,
                  color: isLiked ? AppColors.red : colors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLiked ? AppColors.red : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 글쓰기 페이지 ─────────────────────────────────────────

class _WritePostPage extends ConsumerStatefulWidget {
  const _WritePostPage();

  @override
  ConsumerState<_WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends ConsumerState<_WritePostPage> {
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
        const SnackBar(content: Text('로그인 후 이용할 수 있어요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final post = CommunityPost(
        id: '',
        uid: user.uid,
        nickname: user.displayName ?? '익명',
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
          SnackBar(content: Text('등록 실패: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 22, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '나눔 글쓰기',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                  )
                : Text(
                    '등록',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _canSubmit ? AppColors.accent : colors.inactive,
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('유형', colors: colors),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeChip(
                    label: '후기',
                    icon: Icons.rate_review_outlined,
                    selected: _type == PostType.review,
                    color: AppColors.green,
                    onTap: () => setState(() => _type = PostType.review),
                  ),
                  const SizedBox(width: 10),
                  _TypeChip(
                    label: '팁',
                    icon: Icons.lightbulb_outline_rounded,
                    selected: _type == PostType.tip,
                    color: AppColors.accent,
                    onTap: () => setState(() => _type = PostType.tip),
                  ),
                ],
              ),
              if (_type == PostType.review) ...[
                const SizedBox(height: 20),
                _Label('참기 아이템 (선택)', colors: colors),
                const SizedBox(height: 8),
                _InputField(
                  controller: _itemController,
                  hint: '예) 에어팟 프로, 나이키 운동화',
                  colors: colors,
                ),
                const SizedBox(height: 20),
                _Label('72시간 후 결과', colors: colors),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TypeChip(
                      label: '참았어요',
                      icon: Icons.self_improvement_rounded,
                      selected: _resisted,
                      color: AppColors.blue,
                      onTap: () => setState(() => _resisted = true),
                    ),
                    const SizedBox(width: 10),
                    _TypeChip(
                      label: '샀어요',
                      icon: Icons.shopping_bag_outlined,
                      selected: !_resisted,
                      color: AppColors.green,
                      onTap: () => setState(() => _resisted = false),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _Label('내용', colors: colors),
              const SizedBox(height: 8),
              _InputField(
                controller: _contentController,
                hint: _type == PostType.review
                    ? '72시간 참기 후기를 자유롭게 남겨주세요.'
                    : '소비 습관이나 절약에 도움이 된 팁을 공유해주세요.',
                colors: colors,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 배움 섹션 위젯 ────────────────────────────────────────

const _quote = (
  text: '지금 살 여유가 없는 것을 나중에도 살 여유가 없다.\n하지만 지금 참을 수 있다면 나중엔 더 잘 살 수 있다.',
  author: '— 미니멀리즘 격언',
);

const _consumptionTips = [
  (
    icon: Icons.shopping_cart_outlined,
    color: AppColors.accent,
    title: '장바구니 24시간 방치하기',
    body: '온라인 쇼핑몰 장바구니에 담아두고 하루가 지나도 사고 싶으면 그때 구매하세요. 충동 구매의 70%가 이 과정에서 걸러집니다.',
  ),
  (
    icon: Icons.receipt_long_outlined,
    color: AppColors.green,
    title: '소비 전 "왜?"를 3번 묻기',
    body: '"왜 사고 싶지?" → "정말 필요한가?" → "없으면 어떻게 될까?" 세 질문을 통과한 구매만이 진짜 필요한 소비입니다.',
  ),
  (
    icon: Icons.compare_arrows_rounded,
    color: AppColors.yellow,
    title: '1개 사면 1개 버리기',
    body: '새 물건을 들이기 전에 비슷한 물건을 먼저 처분하는 규칙. 소유물이 늘지 않고 물건의 가치를 더 신중히 따지게 됩니다.',
  ),
];

const _minimalismTips = [
  (
    icon: Icons.home_outlined,
    color: Color(0xFF60A5FA),
    title: '공간이 곧 자유다',
    body: '물건이 많을수록 관리할 것도 많아집니다. 비워진 공간은 새로운 가능성을 만들어줍니다. 소유를 줄이면 마음도 가벼워집니다.',
  ),
  (
    icon: Icons.star_outline_rounded,
    color: AppColors.accent,
    title: '품질 vs 수량',
    body: '싼 물건 10개보다 좋은 물건 1개가 낫습니다. 자주 쓰는 물건에 투자하고, 나머지는 빌리거나 포기하는 습관을 들이세요.',
  ),
];

const _ruleTips = [
  (
    icon: Icons.timer_outlined,
    color: AppColors.accent,
    title: '왜 72시간인가?',
    body: '충동구매 욕구의 피크는 처음 24시간 안에 옵니다. 72시간(3일)이 지나면 욕구가 평균 80% 이상 감소한다는 연구 결과가 있습니다.',
  ),
  (
    icon: Icons.psychology_outlined,
    color: AppColors.green,
    title: '감정과 구매의 연결',
    body: '스트레스, 지루함, 슬픔을 쇼핑으로 해소하려는 패턴을 인식하세요. 감정이 격할 때 등록한 아이템은 72시간 후 대부분 필요 없어집니다.',
  ),
  (
    icon: Icons.trending_up_rounded,
    color: AppColors.yellow,
    title: '절약한 돈의 힘',
    body: '매달 충동구매를 3번만 참아도 연간 수십만 원이 모입니다. 참을 때마다 저축 목표에 그 금액을 이체하면 동기부여가 배가됩니다.',
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

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.colors});
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary),
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

class _InputField extends StatelessWidget {
  const _InputField({
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: colors.textTertiary),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
