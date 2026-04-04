import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/wish_item_model.dart';
import '../providers/wish_item_provider.dart';

class WishItemCard extends ConsumerWidget {
  const WishItemCard({super.key, required this.item});

  final WishItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(clockTickProvider);

    final expired = item.isExpired;
    final percent = (item.progressRatio * 100).toInt();
    final colors = context.colors;

    final bgColor = expired
        ? AppColors.accent.withValues(alpha: context.isDark ? 0.12 : 0.08)
        : colors.surface;

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expired
                ? AppColors.accent.withValues(alpha: 0.4)
                : colors.border,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (item.price != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (expired)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '결정!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  expired
                      ? Icons.alarm_on_rounded
                      : Icons.access_time_rounded,
                  size: 14,
                  color: expired ? AppColors.accent : colors.textTertiary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.remainingText,
                    style: TextStyle(
                      fontSize: 12,
                      color: expired ? AppColors.accent : colors.textTertiary,
                      fontWeight:
                          expired ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: expired ? AppColors.accent : colors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progressRatio,
                minHeight: 5,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation(
                  expired
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '항목 삭제',
          style: TextStyle(color: colors.textPrimary, fontSize: 16),
        ),
        content: Text(
          '"${item.name}"을(를) 삭제할까요?',
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(wishItemNotifierProvider.notifier).deleteItem(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
