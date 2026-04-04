import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            _FilterChips(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyHistory(colors: colors)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
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
      _Filter.all => sorted,
      _Filter.pending =>
        sorted.where((i) => i.status == WishItemStatus.waiting).toList(),
      _Filter.purchased =>
        sorted.where((i) => i.status == WishItemStatus.purchased).toList(),
      _Filter.cancelled =>
        sorted.where((i) => i.status == WishItemStatus.cancelled).toList(),
    };
  }

}

enum _Filter { all, pending, purchased, cancelled }


class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = <({_Filter filter, String label, IconData icon, Color color})>[
      (filter: _Filter.all,       label: '전체',  icon: Icons.apps_rounded,          color: colors.textPrimary),
      (filter: _Filter.pending,   label: '대기중', icon: Icons.access_time_rounded,   color: AppColors.yellow),
      (filter: _Filter.purchased, label: '구매함', icon: Icons.shopping_bag_outlined, color: AppColors.green),
      (filter: _Filter.cancelled, label: '취소함', icon: Icons.close_rounded,         color: AppColors.red),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((entry) {
          final isSelected = selected == entry.filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? entry.color.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? entry.color.withValues(alpha: 0.5)
                        : colors.border,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.icon,
                      size: 16,
                      color: isSelected ? entry.color : colors.inactive,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? entry.color : colors.textTertiary,
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
      return _badge('대기중', colors.surfaceHighlight, colors.textSecondary);
    }
    if (status == WishItemStatus.purchased) {
      return _badge('구매함', AppColors.green.withValues(alpha: 0.15), AppColors.green);
    }
    return _badge('취소함', colors.surfaceHighlight, colors.textTertiary);
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

