import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EmptyWaitingState extends StatelessWidget {
  const EmptyWaitingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.accent.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 20),
            Text(
              '오늘은 욕심이 없는 날이네요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '갖고 싶은 게 생기면 + 버튼으로\n72시간 테스트를 시작해보세요',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
