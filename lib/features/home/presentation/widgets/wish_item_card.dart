import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/wish_item_model.dart';
import '../../domain/models/wish_item_status.dart';
import '../providers/wish_item_provider.dart';

Color _progressColor(double ratio) {
  if (ratio <= 0.25) return const Color(0xFF4A6080); // 다크 블루 — 시작
  if (ratio <= 0.50) return const Color(0xFF4D8FE8); // 소프트 블루 — 진행중
  if (ratio <= 0.75) return const Color(0xFF7BB8F0); // 라이트 블루 — 잘 버티는 중
  return const Color(0xFFFBBF24);                    // 골드 — 거의 완료
}

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
        ? AppColors.green.withValues(alpha: context.isDark ? 0.12 : 0.08)
        : colors.surface;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: expired
                  ? AppColors.green.withValues(alpha: 0.4)
                  : colors.border,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 좌측: 이름, 가격, 남은시간, 그라데이션 바
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
                      if (item.reason != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 11, color: colors.textTertiary),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            expired
                                ? Icons.alarm_on_rounded
                                : Icons.access_time_rounded,
                            size: 13,
                            color: expired ? AppColors.green : colors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.remainingText,
                            style: TextStyle(
                              fontSize: 12,
                              color: expired ? AppColors.green : colors.textTertiary,
                              fontWeight: expired ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _GradientProgressBar(
                        value: item.progressRatio,
                        expired: expired,
                        borderColor: colors.border,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 우측: 원형 타이머
                _CircularTimer(
                  percent: percent,
                  value: item.progressRatio,
                  expired: expired,
                  colors: colors,
                ),
              ],
            ),
            if (expired) ...[
              const SizedBox(height: 14),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DecisionButton(
                      label: '살게요',
                      icon: Icons.shopping_bag_outlined,
                      color: colors.surfaceHighlight,
                      textColor: colors.textTertiary,
                      onTap: () => ref
                          .read(wishItemNotifierProvider.notifier)
                          .updateStatus(item.id, WishItemStatus.purchased),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DecisionButton(
                      label: '참을게요',
                      icon: Icons.self_improvement_rounded,
                      color: AppColors.green,
                      textColor: Colors.white,
                      onTap: () => ref
                          .read(wishItemNotifierProvider.notifier)
                          .updateStatus(item.id, WishItemStatus.cancelled),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
        // 오른쪽 상단 삭제 버튼
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showDeleteDialog(context, ref),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove_rounded, size: 15, color: AppColors.red),
            ),
          ),
        ),
      ],
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
          item.name,
          style: TextStyle(color: colors.textPrimary, fontSize: 16),
        ),
        content: Text(
          '참기를 중지할까요?',
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '계속참기',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(wishItemNotifierProvider.notifier).deleteItem(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              '중지',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// 파스텔 색상 목록 (흐르는 그라데이션용)
const _pastelColors = [
  Color(0xFFFFB3C6), // 핑크
  Color(0xFFCFB3FF), // 라벤더
  Color(0xFFB3D4FF), // 스카이 블루
  Color(0xFFB3FFE0), // 민트
  Color(0xFFFFE0B3), // 피치
  Color(0xFFFFB3C6), // 핑크 (반복 — 루프용)
];

const _pastelExpired = [
  Color(0xFFB3FFCE), // 민트
  Color(0xFFB3FFE8), // 라이트 민트
  Color(0xFFB3F5FF), // 시안
  Color(0xFFB3FFCE), // 민트 (루프)
];

class _GradientProgressBar extends StatefulWidget {
  const _GradientProgressBar({
    required this.value,
    required this.expired,
    required this.borderColor,
  });

  final double value;
  final bool expired;
  final Color borderColor;

  @override
  State<_GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<_GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PastelFlowPainter(
            value: widget.value,
            phase: _controller.value,
            expired: widget.expired,
            borderColor: widget.borderColor,
          ),
          child: const SizedBox(height: 8, width: double.infinity),
        );
      },
    );
  }
}

class _PastelFlowPainter extends CustomPainter {
  _PastelFlowPainter({
    required this.value,
    required this.phase,
    required this.expired,
    required this.borderColor,
  });

  final double value;
  final double phase;
  final bool expired;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final filledW = (w * value).clamp(0.0, w);
    const radius = Radius.circular(4);

    // 배경 트랙
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius),
      Paint()..color = borderColor,
    );

    if (filledW <= 0) return;

    // 파스텔 흐름 — 그라데이션 폭을 3배로 키우고 phase로 슬라이드
    final colors = expired ? _pastelExpired : _pastelColors;
    final gradW = w * 3;
    final offset = -gradW * phase;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h), radius),
    );

    canvas.drawRect(
      Rect.fromLTWH(offset, 0, gradW, h),
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          stops: List.generate(
            colors.length,
            (i) => i / (colors.length - 1),
          ),
        ).createShader(Rect.fromLTWH(offset, 0, gradW, h)),
    );

    // 상단 하이라이트
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h * 0.45), radius),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PastelFlowPainter old) =>
      old.phase != phase || old.value != value || old.expired != expired;
}

class _CircularTimer extends StatelessWidget {
  const _CircularTimer({
    required this.percent,
    required this.value,
    required this.expired,
    required this.colors,
  });

  final int percent;
  final double value;
  final bool expired;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final ringColor = expired ? AppColors.green : _progressColor(value);

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 링
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation(colors.border),
          ),
          // 진행 링
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 5,
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation(ringColor),
          ),
          // 중앙 텍스트
          if (expired)
            Text(
              '결정!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    height: 1,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: colors.textTertiary,
                    height: 1,
                  ),
                ),
              ],
            ),
        ],
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
