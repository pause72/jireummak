import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local/wish_image_local_store.dart';
import '../../domain/models/wish_item_model.dart';
import '../../domain/models/wish_item_status.dart';
import '../providers/wish_item_provider.dart';

Color _progressColor(double ratio) {
  if (ratio <= 0.25) return const Color(0xFF5B8DB8);
  if (ratio <= 0.50) return const Color(0xFF4D8FE8);
  if (ratio <= 0.75) return const Color(0xFF9BCBF5);
  return const Color(0xFFF59E0B);
}

// ── 최초 1회 스와이프 힌트 상태 (메모리 기반, 세션 1회) ──────────────
bool _swipeHintPlayed = false;

class WishItemCard extends ConsumerStatefulWidget {
  const WishItemCard({super.key, required this.item, this.isFirst = false});

  final WishItem item;
  final bool isFirst;

  @override
  ConsumerState<WishItemCard> createState() => _WishItemCardState();
}

class _WishItemCardState extends ConsumerState<WishItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  late final Animation<Offset> _hintAnim;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hintAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.08, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.08, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_hintController);

    if (widget.isFirst && !_swipeHintPlayed && !widget.item.isExpired) {
      _swipeHintPlayed = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _hintController.forward();
      });
    }
  }

  static const _resistMessages = [
    ('🎉', '잘 참았어요!', '72시간을 버텨낸 현명한 선택이에요.\n이 절약이 쌓여 큰 자산이 될 거예요.'),
    ('💪', '충동을 이겼어요!', '참을 때마다 조금씩 더 강해지고 있어요.\n오늘의 절약, 정말 잘했어요!'),
    ('🌱', '훌륭해요!', '72시간이 지나 마음이 식었다면,\n그건 처음부터 충동이었던 거예요.'),
    ('✨', '멋진 선택이에요!', '사지 않는 것도 훌륭한 소비예요.\n절약한 돈은 더 의미 있는 곳에 쓰일 거예요.'),
    ('🏆', '대단해요!', '스스로를 이겨낸 오늘이 자랑스러워요.\n이 습관이 미래를 바꿔줄 거예요.'),
  ];

  static const _purchaseMessages = [
    ('🛒', '72시간 고민 끝의 선택이에요!', '구매 전 최저가를 꼭 확인하세요.\n네이버쇼핑이나 다나와를 활용해보세요!'),
    ('💡', '충분히 생각한 소비예요!', '구매 전 리뷰를 한 번 더 확인하고,\n최저가 알림을 설정해두면 더 좋아요.'),
    ('✅', '현명한 소비예요!', '충동이 아닌 확신으로 내린 결정이에요.\n좋은 가격에 구매하길 바라요!'),
    ('💰', '진짜 필요한 거니까 사는 거예요!', '구매 전 최저가 한 번만 더 확인해봐요.\n잘 쓰면 그것도 현명한 소비예요.'),
  ];

  void _showEncouragement(BuildContext context, {required bool resisted}) {
    final messages = resisted ? _resistMessages : _purchaseMessages;
    final msg = messages[Random().nextInt(messages.length)];
    final colors = context.colors;
    final accentColor = resisted ? AppColors.green : AppColors.accent;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg.$1, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              msg.$2,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              msg.$3,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetCtx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '좋아요!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _showContextMenu(BuildContext context, {Offset? globalPosition}) async {
    final colors = context.colors;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;

    final Offset pos = globalPosition ?? (overlay.size.center(Offset.zero));
    final position = RelativeRect.fromRect(
      pos & const Size(1, 1),
      Offset.zero & overlay.size,
    );

    final value = await showMenu<String>(
      context: context,
      position: position,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'edit',
          height: 44,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: colors.textSecondary),
              const SizedBox(width: 10),
              Text('수정', style: TextStyle(fontSize: 14, color: colors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 44,
          child: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red),
              SizedBox(width: 10),
              Text('삭제', style: TextStyle(fontSize: 14, color: AppColors.red)),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;
    if (value == 'edit') _showEditSheet(this.context);
    if (value == 'delete') _confirmDelete(this.context);
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditItemSheet(item: widget.item, ref: ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(widget.item.name, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
        content: Text(AppStrings.cardDeleteContent, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cardDeleteCancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.cardDeleteConfirm, style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(wishItemNotifierProvider.notifier).deleteItem(widget.item.id);
      await WishImageLocalStore.delete(widget.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(clockTickProvider);

    final item = widget.item;
    final expired = item.isExpired;
    final percent = (item.progressRatio * 100).toInt();
    final colors = context.colors;

    final bgColor = expired
        ? AppColors.green.withValues(alpha: context.isDark ? 0.12 : 0.08)
        : colors.surface;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 22),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item.name, style: TextStyle(color: colors.textPrimary, fontSize: 16)),
          content: Text(AppStrings.cardDeleteContent, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppStrings.cardDeleteCancel, style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(AppStrings.cardDeleteConfirm, style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        await ref.read(wishItemNotifierProvider.notifier).deleteItem(item.id);
        await WishImageLocalStore.delete(item.id);
      },
      child: SlideTransition(
        position: _hintAnim,
        child: GestureDetector(
          onLongPressStart: expired
              ? null
              : (details) {
                  HapticFeedback.mediumImpact();
                  _showContextMenu(context, globalPosition: details.globalPosition);
                },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: expired
                    ? AppColors.green.withValues(alpha: 0.4)
                    : colors.border,
              ),
              boxShadow: context.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 상단 행: 썸네일 | 이름+가격+이유 | 원형 타이머
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _WishItemThumbnail(itemId: item.id),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.price != null)
                            Padding(
                              // ··· 버튼 공간 확보
                              padding: EdgeInsets.only(right: expired ? 0 : 20),
                              child: Text(
                                item.formattedPrice,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: item.price != null ? 2 : 0,
                              // 가격 없을 때만 이름에 ··· 공간 확보
                              right: (item.price == null && !expired) ? 20 : 0,
                            ),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.reason != null) ...[
                            const SizedBox(height: 4),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(top: expired ? 0 : 20),
                      child: _CircularTimer(
                        percent: percent,
                        value: item.progressRatio,
                        expired: expired,
                        colors: colors,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── 하단 행: 프로그레스 바 | 남은 시간
                Row(
                  children: [
                    Expanded(
                      child: _GradientProgressBar(
                        value: item.progressRatio,
                        expired: expired,
                        borderColor: colors.border,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          expired ? Icons.alarm_on_rounded : Icons.access_time_rounded,
                          size: 12,
                          color: expired ? AppColors.green : colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.remainingText,
                          style: TextStyle(
                            fontSize: 11,
                            color: expired ? AppColors.green : colors.textTertiary,
                            fontWeight: expired ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
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
                          label: AppStrings.cardBuy,
                          icon: Icons.shopping_bag_outlined,
                          color: colors.surfaceHighlight,
                          textColor: colors.textTertiary,
                          onTap: () => _showPurchaseChecklist(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DecisionButton(
                          label: AppStrings.cardResist,
                          icon: Icons.self_improvement_rounded,
                          color: AppColors.green,
                          textColor: Colors.white,
                          onTap: () {
                            _showEncouragement(context, resisted: true);
                            ref
                                .read(wishItemNotifierProvider.notifier)
                                .updateStatus(item.id, WishItemStatus.cancelled);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
                // ── 우측 상단 ··· 버튼
                if (!expired)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        _showContextMenu(context, globalPosition: details.globalPosition);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.more_horiz, size: 18, color: colors.inactive),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseChecklist(BuildContext context) {
    final colors = context.colors;
    final checks = [false, false, false];
    final questions = [
      AppStrings.checklistQ1,
      AppStrings.checklistQ2,
      AppStrings.checklistQ3,
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Text('🛒', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(AppStrings.checklistTitle, style: TextStyle(fontSize: 16, color: colors.textPrimary)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(questions.length, (i) => CheckboxListTile(
              value: checks[i],
              onChanged: (v) => setState(() => checks[i] = v ?? false),
              title: Text(questions[i], style: TextStyle(fontSize: 13, color: colors.textSecondary)),
              activeColor: AppColors.accent,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showEncouragement(context, resisted: false);
                ref.read(wishItemNotifierProvider.notifier)
                    .updateStatus(widget.item.id, WishItemStatus.purchased);
              },
              child: Text(AppStrings.checklistConfirm, style: TextStyle(color: colors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 수정 바텀시트 ────────────────────────────────────────────

class _EditItemSheet extends StatefulWidget {
  const _EditItemSheet({required this.item, required this.ref});

  final WishItem item;
  final WidgetRef ref;

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _reasonController;

  String? _nameError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(
      text: widget.item.price != null ? widget.item.price!.toInt().toString() : '',
    );
    _reasonController = TextEditingController(text: widget.item.reason ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = AppStrings.homeItemNameRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    final price = double.tryParse(_priceController.text.trim());
    final reason = _reasonController.text.trim();

    await widget.ref.read(wishItemNotifierProvider.notifier).updateItem(
          widget.item.id,
          name: name,
          price: price,
          reason: reason.isNotEmpty ? reason : null,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '참기 수정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          const SizedBox(height: 20),
          _EditField(
            controller: _nameController,
            hint: AppStrings.homeItemNameHint,
            autofocus: true,
            maxLength: 20,
            errorText: _nameError,
            onChanged: (_) { if (_nameError != null) setState(() => _nameError = null); },
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _priceController,
            hint: AppStrings.homePriceHint,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _reasonController,
            hint: AppStrings.homeReasonHint,
            maxLength: 30,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('수정 완료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
        errorText: errorText,
        filled: true,
        fillColor: colors.background,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

// ── 프로그레스 바 흐름 색상 ────────────────────────────────────

const _pastelColors = [
  Color(0xFF60A5FA),
  Color(0xFF818CF8),
  Color(0xFF34D399),
  Color(0xFF60A5FA),
];

const _pastelExpired = [
  Color(0xFF34D399),
  Color(0xFF6EE7B7),
  Color(0xFF10B981),
  Color(0xFF34D399),
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
          child: const SizedBox(height: 6, width: double.infinity),
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
    const radius = Radius.circular(3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius),
      Paint()..color = borderColor,
    );

    if (filledW <= 0) return;

    final colors = expired ? _pastelExpired : _pastelColors;
    final gradW = w * 3;
    final offset = -gradW * (1 - phase);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledW, h), radius),
    );

    canvas.drawRect(
      Rect.fromLTWH(offset, 0, gradW, h),
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
        ).createShader(Rect.fromLTWH(offset, 0, gradW, h)),
    );

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
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation(colors.border),
          ),
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation(ringColor),
          ),
          if (expired)
            Text(
              AppStrings.cardDecisionBadge,
              style: const TextStyle(
                fontSize: 11,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    height: 1,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 11,
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

// ── 좌측 썸네일 (탭 → 전체화면) ─────────────────────────

class _WishItemThumbnail extends StatefulWidget {
  const _WishItemThumbnail({required this.itemId});
  final String itemId;

  @override
  State<_WishItemThumbnail> createState() => _WishItemThumbnailState();
}

class _WishItemThumbnailState extends State<_WishItemThumbnail> {
  File? _file;

  @override
  void initState() {
    super.initState();
    WishImageLocalStore.getFile(widget.itemId).then((f) {
      if (mounted && f != null) setState(() => _file = f);
    });
  }

  void _showFullscreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(_file!, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(_file!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
