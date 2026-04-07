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
            _FilterChips(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
              items: all,
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
    return switch (_filter) {
      _Filter.all => sorted
          .where((i) =>
              i.status == WishItemStatus.cancelled ||
              i.status == WishItemStatus.purchased)
          .toList(),
      _Filter.resisted =>
        sorted.where((i) => i.status == WishItemStatus.cancelled).toList(),
      _Filter.purchased =>
        sorted.where((i) => i.status == WishItemStatus.purchased).toList(),
    };
  }

}

enum _Filter { all, resisted, purchased }


class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.items,
  });

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;
  final List<WishItem> items;

  int _count(_Filter filter) => switch (filter) {
        _Filter.all =>
          items.where((i) => i.status == WishItemStatus.cancelled || i.status == WishItemStatus.purchased).length,
        _Filter.resisted =>
          items.where((i) => i.status == WishItemStatus.cancelled).length,
        _Filter.purchased =>
          items.where((i) => i.status == WishItemStatus.purchased).length,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = <({_Filter filter, String label, IconData icon, Color color})>[
      (filter: _Filter.all,      label: '전체', icon: Icons.grid_view_rounded,        color: const Color(0xFF6B7280)),
      (filter: _Filter.resisted, label: '참음', icon: Icons.self_improvement_rounded, color: AppColors.blue),
      (filter: _Filter.purchased,label: '구매', icon: Icons.shopping_bag_outlined,    color: AppColors.green),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((entry) {
          final isSelected = selected == entry.filter;
          final count = _count(entry.filter);

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
                    if (count > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : colors.textTertiary,
                        ),
                      ),
                    ],
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _dateText(item.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: item.status, isExpired: item.isExpired),
            ],
          ),
          if (item.price != null) ...[
            const SizedBox(height: 6),
            Text(
              item.formattedPrice,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
          if (item.reason != null) ...[
            const SizedBox(height: 6),
            Text(
              '"${item.reason}"',
              style: TextStyle(
                fontSize: 12,
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
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
      return _badge('구매', AppColors.green.withValues(alpha: 0.15), AppColors.green);
    }
    return _badge('참음', AppColors.blue.withValues(alpha: 0.15), AppColors.blue);
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

