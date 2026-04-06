import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/wish_item_model.dart';
import '../../domain/models/wish_item_status.dart';
import '../providers/wish_item_provider.dart';

Color _progressColor(double ratio) {
  if (ratio <= 0.25) return const Color(0xFF94A3B8); // 슬레이트 — 시작
  if (ratio <= 0.50) return const Color(0xFF60A5FA); // 블루 — 진행중
  if (ratio <= 0.75) return const Color(0xFF2DD4BF); // 틸 — 잘 버티는 중
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

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, ref),
      child: Container(
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
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageColor =
        widget.expired ? AppColors.green : _progressColor(widget.value);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WaveProgressPainter(
            value: widget.value,
            phase: _controller.value,
            stageColor: stageColor,
            borderColor: widget.borderColor,
          ),
          child: const SizedBox(height: 12, width: double.infinity),
        );
      },
    );
  }
}

class _WaveProgressPainter extends CustomPainter {
  _WaveProgressPainter({
    required this.value,
    required this.phase,
    required this.stageColor,
    required this.borderColor,
  });

  final double value;
  final double phase;
  final Color stageColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final filledW = (w * value).clamp(0.0, w);
    const radius = Radius.circular(6);

    // 배경
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius),
      Paint()..color = borderColor,
    );

    if (filledW <= 0) return;

    // 채워진 영역으로 클리핑
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h), radius),
    );

    // 그라데이션 베이스
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h), radius),
      Paint()
        ..shader = LinearGradient(
          colors: [
            stageColor.withValues(alpha: 0.45),
            stageColor.withValues(alpha: 0.75),
          ],
        ).createShader(Rect.fromLTWH(0, 0, filledW, h)),
    );

    // 물결 레이어 (두 파형을 겹쳐서 자연스럽게)
    _drawWave(canvas, size, filledW, phase, stageColor.withValues(alpha: 0.35));
    _drawWave(canvas, size, filledW, phase + 0.5, stageColor.withValues(alpha: 0.2));

    // 상단 하이라이트
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, filledW, h * 0.4),
        radius,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    canvas.restore();

    // 글로우
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h), radius),
      Paint()
        ..color = stageColor.withValues(alpha: 0.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double filledW,
    double phase,
    Color color,
  ) {
    final h = size.height;
    final amplitude = h * 0.35;
    final waveLen = filledW * 0.7;
    final midY = h * 0.52;

    final path = Path()..moveTo(0, h);
    for (double x = 0; x <= filledW; x++) {
      final y = midY + sin((x / waveLen * 2 * pi) + (phase * 2 * pi)) * amplitude;
      path.lineTo(x, y);
    }
    path
      ..lineTo(filledW, h)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WaveProgressPainter old) =>
      old.phase != phase ||
      old.value != value ||
      old.stageColor != stageColor;
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
            valueColor: AlwaysStoppedAnimation(
              colors.border,
            ),
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
