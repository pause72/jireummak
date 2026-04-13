import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/domain/models/wish_stats.dart';
import '../../../../features/home/presentation/providers/wish_item_provider.dart';

class StatsDetailPage extends ConsumerWidget {
  const StatsDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wishStatsProvider);
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
          '통계',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _SavedAmountCard(stats: stats),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(label: '참음', value: '${stats.cancelledCount}번', icon: Icons.self_improvement_rounded, color: AppColors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: '구매', value: '${stats.purchasedCount}번', icon: Icons.shopping_bag_outlined, color: AppColors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(label: '참기', value: '${stats.waitingCount}개', icon: Icons.timer_outlined, color: AppColors.yellow)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: '총 등록', value: '${stats.totalCount}개', icon: Icons.list_alt_rounded, color: AppColors.accent)),
              ],
            ),
            if (stats.decidedCount > 0) ...[
              const SizedBox(height: 16),
              _SaveRateCard(stats: stats),
            ],
            const SizedBox(height: 16),
            _MotivationCard(stats: stats),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SavedAmountCard extends StatelessWidget {
  const _SavedAmountCard({required this.stats});
  final WishStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          const Text(
            '총 절약 금액',
            style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            stats.savedAmount == 0 ? '₩ 0원' : stats.formattedSaved,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (stats.spentAmount > 0) ...[
            const SizedBox(height: 8),
            Text('구매 지출 ${stats.formattedSpent}', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _SaveRateCard extends StatelessWidget {
  const _SaveRateCard({required this.stats});
  final WishStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rate = stats.saveRate;
    final percent = (rate * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('충동구매 저항률', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
              Text('$percent%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '결정한 ${stats.decidedCount}건 중 ${stats.cancelledCount}건 참음',
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.stats});
  final WishStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (message, sub) = _getMessage(stats);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.textPrimary, height: 1.5)),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
        ],
      ),
    );
  }

  (String, String) _getMessage(WishStats s) {
    if (s.totalCount == 0) return ('아직 기록이 없어요.', '갖고 싶은 게 생기면 글쓰기버튼으로 72시간 참기를 시작해보세요.');
    if (s.cancelledCount == 0) return ('아직 참은 항목이 없어요.', '72시간이 지나면 진짜 필요한지 다시 생각해보세요.');
    if (s.saveRate >= 0.8) return ('대단해요! 충동구매를 잘 참고 있어요.', '절약한 금액으로 더 의미 있는 것에 투자해보세요.');
    if (s.saveRate >= 0.5) return ('좋은 습관을 만들어가고 있어요.', '72시간 후 다시 생각하면 불필요한 소비가 보여요.');
    return ('조금씩 더 참아봐요.', '충동구매를 줄이면 소비 습관이 달라져요.');
  }
}
