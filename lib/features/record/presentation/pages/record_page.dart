import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/domain/models/wish_item_model.dart';
import '../../../../features/home/domain/models/wish_item_status.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

enum _Filter { all, resisted, purchased }

enum _Sort { recent, priceHigh }

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.recent;

  List<WishItem> _applyFilter(List<WishItem> items) {
    final byFilter = switch (_filter) {
      _Filter.all => items.where(
          (i) =>
              i.status == WishItemStatus.cancelled ||
              i.status == WishItemStatus.purchased,
        ),
      _Filter.resisted =>
        items.where((i) => i.status == WishItemStatus.cancelled),
      _Filter.purchased =>
        items.where((i) => i.status == WishItemStatus.purchased),
    }.toList();

    byFilter.sort(
      (a, b) => switch (_sort) {
        _Sort.recent => b.createdAt.compareTo(a.createdAt),
        _Sort.priceHigh => (b.price ?? 0).compareTo(a.price ?? 0),
      },
    );

    return byFilter;
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allItemsProvider);
    final colors = context.colors;

    final resisted =
        all.where((i) => i.status == WishItemStatus.cancelled).toList();
    final purchased =
        all.where((i) => i.status == WishItemStatus.purchased).toList();

    final filtered = _applyFilter(all);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 성과 요약 카드
            if (resisted.isNotEmpty || purchased.isNotEmpty)
              _SummaryCard(resisted: resisted, purchased: purchased),
            // ── 필터 + 정렬
            Row(
              children: [
                Expanded(
                  child: _FilterChips(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    allCount: resisted.length + purchased.length,
                    resistedCount: resisted.length,
                    purchasedCount: purchased.length,
                  ),
                ),
                _SortButton(
                  sort: _sort,
                  onChanged: (s) => setState(() => _sort = s),
                ),
              ],
            ),
            // ── 리스트
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
}

// ── 성과 요약 카드 ───────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.resisted, required this.purchased});

  final List<WishItem> resisted;
  final List<WishItem> purchased;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalSaved = resisted.fold(0.0, (sum, i) => sum + (i.price ?? 0));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green.withValues(alpha: 0.14),
            AppColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💰 지금까지 아낀 금액',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(totalSaved.toInt()),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatRow('🔥 참기 성공', '${resisted.length}회', AppColors.green, colors),
              const SizedBox(height: 6),
              _StatRow('🛍️ 구매', '${purchased.length}회', AppColors.yellow, colors),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatAmount(int n) {
    if (n <= 0) return '₩ 0원';
    final s = n.toString();
    final buf = StringBuffer('₩ ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    buf.write('원');
    return buf.toString();
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value, this.color, this.colors);

  final String label;
  final String value;
  final Color color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── 필터 칩 (숫자 포함) ──────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.resistedCount,
    required this.purchasedCount,
  });

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;
  final int allCount;
  final int resistedCount;
  final int purchasedCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filters = <({_Filter filter, String label, int count, IconData icon, Color color})>[
      (
        filter: _Filter.all,
        label: '전체',
        count: allCount,
        icon: Icons.grid_view_rounded,
        color: AppColors.accent,
      ),
      (
        filter: _Filter.resisted,
        label: '참음',
        count: resistedCount,
        icon: Icons.self_improvement_rounded,
        color: AppColors.green,
      ),
      (
        filter: _Filter.purchased,
        label: '구매',
        count: purchasedCount,
        icon: Icons.shopping_bag_outlined,
        color: AppColors.yellow,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                      size: 14,
                      color: isSelected ? Colors.white : colors.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.count > 0 ? '${entry.label} ${entry.count}' : entry.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
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

// ── 정렬 버튼 ────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onChanged});

  final _Sort sort;
  final ValueChanged<_Sort> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<_Sort>(
      onSelected: onChanged,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      icon: Icon(Icons.sort_rounded, size: 20, color: colors.textSecondary),
      itemBuilder: (_) => [
        _sortItem(_Sort.recent, '최근순', sort),
        _sortItem(_Sort.priceHigh, '금액 높은순', sort),
      ],
    );
  }

  PopupMenuItem<_Sort> _sortItem(_Sort value, String label, _Sort current) {
    return PopupMenuItem(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            size: 16,
            color: current == value ? AppColors.accent : Colors.transparent,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ── 기록 카드 ────────────────────────────────────────────────

class _HistoryItemCard extends ConsumerWidget {
  const _HistoryItemCard({required this.item});

  final WishItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsDecision =
        item.status == WishItemStatus.waiting && item.isExpired;
    final colors = context.colors;
    final isResisted = item.status == WishItemStatus.cancelled;
    final isPurchased = item.status == WishItemStatus.purchased;

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
          // ── 가격 (상태에 따라 의미 부여) | 날짜
          if (item.price != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (isResisted)
                  Text(
                    '${item.formattedPrice} 아낌',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  )
                else if (isPurchased)
                  Text(
                    '${item.formattedPrice} 사용',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.yellow,
                    ),
                  )
                else
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
                  _dateText(item),
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              _dateText(item),
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
          // ── 결정 버튼 (대기 만료)
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

  String _dateText(WishItem item) {
    final base = item.decidedAt ?? item.createdAt;
    final diff = DateTime.now().difference(base);
    final ago = diff.inDays > 0
        ? '${diff.inDays}일 전'
        : diff.inHours > 0
            ? '${diff.inHours}시간 전'
            : '방금 전';

    return switch (item.status) {
      WishItemStatus.cancelled => '참기 성공 $ago',
      WishItemStatus.purchased => '구매 $ago',
      _ => ago,
    };
  }
}

// ── 상태 뱃지 (감정형) ───────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isExpired});

  final WishItemStatus status;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (status == WishItemStatus.waiting) {
      if (isExpired) return _badge('결정!', AppColors.accent, Colors.white);
      return _badge('참기 중', colors.surfaceHighlight, colors.textSecondary);
    }
    if (status == WishItemStatus.purchased) {
      return _badge(
        '구매 😅',
        AppColors.yellow.withValues(alpha: 0.18),
        AppColors.yellow,
      );
    }
    return _badge(
      '성공 💪',
      AppColors.green.withValues(alpha: 0.18),
      AppColors.green,
    );
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

// ── 결정 버튼 ────────────────────────────────────────────────

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

// ── 빈 상태 ─────────────────────────────────────────────────

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
