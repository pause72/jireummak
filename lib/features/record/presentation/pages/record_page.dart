import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/ads/ad_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/domain/models/wish_item_model.dart';
import '../../../../features/home/domain/models/wish_item_status.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  _Filter _filter = _Filter.all;
  final _searchController = TextEditingController();
  String _query = '';
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allItemsProvider);
    final filtered = _applyFilter(all);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isBannerLoaded)
              SizedBox(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            _SearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              colors: colors,
            ),
            _FilterChips(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyHistory(colors: colors)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryItemCard(item: filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<WishItem> _applyFilter(List<WishItem> items) {
    final sorted = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final byFilter = switch (_filter) {
      _Filter.all => sorted.where((i) =>
          i.status == WishItemStatus.cancelled ||
          i.status == WishItemStatus.purchased),
      _Filter.resisted =>
        sorted.where((i) => i.status == WishItemStatus.cancelled),
      _Filter.purchased =>
        sorted.where((i) => i.status == WishItemStatus.purchased),
    };
    if (_query.isEmpty) return byFilter.toList();
    final q = _query.toLowerCase();
    return byFilter.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

}

enum _Filter { all, resisted, purchased }


class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.colors,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: '검색',
          hintStyle: TextStyle(fontSize: 14, color: colors.textTertiary),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textTertiary),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(Icons.close_rounded, size: 18, color: colors.textTertiary),
                )
              : null,
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = <({_Filter filter, String label, IconData icon, Color color})>[
      (filter: _Filter.all,       label: '전체', icon: Icons.grid_view_rounded,        color: AppColors.accent),
      (filter: _Filter.resisted,  label: '참음', icon: Icons.self_improvement_rounded, color: AppColors.green),
      (filter: _Filter.purchased, label: '구매', icon: Icons.shopping_bag_outlined,    color: AppColors.yellow),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((entry) {
          final isSelected = selected == entry.filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? entry.color : colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? entry.color : colors.border,
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: entry.color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.icon,
                      size: 15,
                      color: isSelected ? Colors.white : colors.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.label,
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

class _HistoryItemCard extends ConsumerWidget {
  const _HistoryItemCard({required this.item});

  final WishItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsDecision =
        item.status == WishItemStatus.waiting && item.isExpired;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsDecision
              ? AppColors.accent.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 상품명 | 뱃지
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: item.status, isExpired: item.isExpired),
            ],
          ),
          // ── 가격 | 날짜
          if (item.price != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  item.formattedPrice,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _dateText(item.createdAt),
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              _dateText(item.createdAt),
              style: TextStyle(fontSize: 11, color: colors.textTertiary),
            ),
          ],
          // ── 이유
          if (item.reason != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.reason!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (needsDecision) ...[
            const SizedBox(height: 14),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DecisionButton(
                    label: '안 살게요',
                    icon: Icons.close_rounded,
                    color: colors.surfaceHighlight,
                    textColor: colors.textSecondary,
                    onTap: () => ref
                        .read(wishItemNotifierProvider.notifier)
                        .updateStatus(item.id, WishItemStatus.cancelled),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DecisionButton(
                    label: '살게요',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.accent,
                    textColor: Colors.white,
                    onTap: () => ref
                        .read(wishItemNotifierProvider.notifier)
                        .updateStatus(item.id, WishItemStatus.purchased),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dateText(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    return '방금 전';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isExpired});

  final WishItemStatus status;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (status == WishItemStatus.waiting) {
      if (isExpired) return _badge('결정!', AppColors.accent, Colors.white);
      return _badge('참기', colors.surfaceHighlight, colors.textSecondary);
    }
    if (status == WishItemStatus.purchased) {
      return _badge('구매', AppColors.yellow.withValues(alpha: 0.18), AppColors.yellow);
    }
    return _badge('참음', AppColors.green.withValues(alpha: 0.18), AppColors.green);
  }

  Widget _badge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 총 절약금액 배너 ──────────────────────────────────────


class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 56, color: colors.border),
          const SizedBox(height: 16),
          Text(
            '아직 기록이 없어요',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

