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


  void _showEncouragement(BuildContext context, {required bool resisted}) {
    final messages = resisted ? AppStrings.resistMessages : AppStrings.purchaseMessages;
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
                  AppStrings.encouragementButton,
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
              Text(AppStrings.cardMenuEdit, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
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
              Text(AppStrings.cardMenuDelete, style: TextStyle(fontSize: 14, color: AppColors.red)),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;
    if (value == 'edit') _showEditSheet(this.context);
    if (value == 'delete') _confirmDelete(this.context);
  }

  void _showReasonsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReasonsSheet(item: widget.item, ref: ref),
    );
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
          onTap: expired
              ? null
              : () => _showReasonsSheet(context),
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

// ── 이유 입력 바텀시트 ──────────────────────────────────────────

const _buyChips = AppStrings.buyChips;
const _resistChips = AppStrings.resistChips;

class _ReasonsSheet extends StatefulWidget {
  const _ReasonsSheet({required this.item, required this.ref});

  final WishItem item;
  final WidgetRef ref;

  @override
  State<_ReasonsSheet> createState() => _ReasonsSheetState();
}

class _ReasonsSheetState extends State<_ReasonsSheet> {
  late List<TextEditingController> _buyControllers;
  late List<TextEditingController> _resistControllers;
  Set<String> _selectedBuyChips = {};
  Set<String> _selectedResistChips = {};
  bool _buyExpanded = false;
  bool _resistExpanded = true;
  bool _isSubmitting = false;

  TextEditingController _makeCtrl(String text) {
    final c = TextEditingController(text: text);
    c.addListener(_onTextChanged);
    return c;
  }

  void _disposeCtrl(TextEditingController c) {
    c.removeListener(_onTextChanged);
    c.dispose();
  }

  @override
  void initState() {
    super.initState();
    final buy = widget.item.buyReasons;
    final resist = widget.item.resistReasons;
    _buyControllers = buy.isEmpty
        ? [_makeCtrl('')]
        : buy.map(_makeCtrl).toList();
    _resistControllers = resist.isEmpty
        ? [_makeCtrl('')]
        : resist.map(_makeCtrl).toList();
    _syncSelectedChips();
  }

  void _onTextChanged() => setState(_syncSelectedChips);

  void _syncSelectedChips() {
    final buyTexts = _buyControllers.map((c) => c.text.trim()).toSet();
    _selectedBuyChips = _buyChips.where(buyTexts.contains).toSet();
    final resistTexts = _resistControllers.map((c) => c.text.trim()).toSet();
    _selectedResistChips = _resistChips.where(resistTexts.contains).toSet();
  }

  @override
  void dispose() {
    for (final c in [..._buyControllers, ..._resistControllers]) {
      _disposeCtrl(c);
    }
    super.dispose();
  }

  void _addField(List<TextEditingController> controllers) {
    setState(() => controllers.add(_makeCtrl('')));
  }

  void _removeField(List<TextEditingController> controllers, int index) {
    setState(() {
      _disposeCtrl(controllers[index]);
      controllers.removeAt(index);
      if (controllers.isEmpty) controllers.add(_makeCtrl(''));
      _syncSelectedChips();
    });
  }

  void _toggleChip(
    List<TextEditingController> controllers,
    Set<String> selectedSet,
    String text,
  ) {
    setState(() {
      if (selectedSet.contains(text)) {
        final idx = controllers.indexWhere((c) => c.text.trim() == text);
        if (idx >= 0) {
          if (controllers.length == 1) {
            controllers[idx].clear();
          } else {
            _disposeCtrl(controllers[idx]);
            controllers.removeAt(idx);
          }
        }
      } else {
        final emptyIdx = controllers.indexWhere((c) => c.text.trim().isEmpty);
        if (emptyIdx >= 0) {
          controllers[emptyIdx].text = text;
        } else {
          controllers.add(_makeCtrl(text));
        }
      }
      _syncSelectedChips();
    });
  }

  int get _buyCount =>
      _buyControllers.where((c) => c.text.trim().isNotEmpty).length;
  int get _resistCount =>
      _resistControllers.where((c) => c.text.trim().isNotEmpty).length;

  String _feedbackMessage(int buy, int resist) {
    if (resist > buy) return AppStrings.reasonsFeedbackResistMore;
    if (buy > resist) return AppStrings.reasonsFeedbackBuyMore;
    return AppStrings.reasonsFeedbackDefault;
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final buyReasons = _buyControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final resistReasons = _resistControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await widget.ref.read(wishItemNotifierProvider.notifier).updateReasons(
          widget.item.id,
          buyReasons: buyReasons,
          resistReasons: resistReasons,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_feedbackMessage(buyReasons.length, resistReasons.length)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasAny = _buyCount + _resistCount > 0;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.reasonsSheetSubtitle,
                      style: TextStyle(fontSize: 12, color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.close, size: 20, color: colors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── 필요없는 이유 (상단 배치 + 기본 펼침 — 앱 핵심) ──
          _ReasonSection(
            label: AppStrings.reasonsResistLabel,
            icon: Icons.remove_rounded,
            labelColor: AppColors.green,
            chips: _resistChips,
            selectedChips: _selectedResistChips,
            controllers: _resistControllers,
            colors: colors,
            expanded: _resistExpanded,
            onToggle: () => setState(() => _resistExpanded = !_resistExpanded),
            onChipTap: (text) => _toggleChip(_resistControllers, _selectedResistChips, text),
            onAdd: () => _addField(_resistControllers),
            onRemove: (i) => _removeField(_resistControllers, i),
          ),
          const SizedBox(height: 10),

          // ── 필요한 이유 (하단 배치 + 기본 접힘) ──
          _ReasonSection(
            label: AppStrings.reasonsBuyLabel,
            icon: Icons.add_rounded,
            labelColor: AppColors.accent,
            chips: _buyChips,
            selectedChips: _selectedBuyChips,
            controllers: _buyControllers,
            colors: colors,
            expanded: _buyExpanded,
            onToggle: () => setState(() => _buyExpanded = !_buyExpanded),
            onChipTap: (text) => _toggleChip(_buyControllers, _selectedBuyChips, text),
            onAdd: () => _addField(_buyControllers),
            onRemove: (i) => _removeField(_buyControllers, i),
          ),

          // ── 비율 시각화 ──
          if (hasAny) ...[
            const SizedBox(height: 12),
            _RatioBar(buyCount: _buyCount, resistCount: _resistCount, colors: colors),
          ],

          const SizedBox(height: 14),

          // ── 미래 관점 힌트 ──
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 13, color: colors.textTertiary),
              const SizedBox(width: 6),
              Text(
                AppStrings.reasonsHint1,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 13, color: colors.textTertiary),
              const SizedBox(width: 6),
              Text(
                AppStrings.reasonsHint2,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── CTA ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      AppStrings.reasonsCtaButton,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 접기/펼치기 섹션 ──────────────────────────────────────────

class _ReasonSection extends StatelessWidget {
  const _ReasonSection({
    required this.label,
    required this.icon,
    required this.labelColor,
    required this.chips,
    required this.selectedChips,
    required this.controllers,
    required this.colors,
    required this.expanded,
    required this.onToggle,
    required this.onChipTap,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final IconData icon;
  final Color labelColor;
  final List<String> chips;
  final Set<String> selectedChips;
  final List<TextEditingController> controllers;
  final AppColors colors;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onChipTap;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  int get _filledCount =>
      controllers.where((c) => c.text.trim().isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expanded
              ? labelColor.withValues(alpha: 0.45)
              : colors.border,
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // 헤더 (항상 보임)
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: labelColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 13, color: labelColor),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                  const Spacer(),
                  if (_filledCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: labelColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppStrings.reasonsFilledCount(_filledCount),
                        style: TextStyle(
                          fontSize: 10,
                          color: labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 펼쳐지는 내용
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: colors.border),
                  const SizedBox(height: 10),
                  // 추천 칩
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chips
                        .map(
                          (chip) => _SelectableChip(
                            text: chip,
                            selected: selectedChips.contains(chip),
                            color: labelColor,
                            onTap: () => onChipTap(chip),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  // 동적 입력 필드 목록
                  ...List.generate(controllers.length, (i) {
                    final isOnly = controllers.length == 1;
                    final isEmpty = controllers[i].text.trim().isEmpty;
                    return Padding(
                      padding: EdgeInsets.only(top: i > 0 ? 6 : 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _EditField(
                              controller: controllers[i],
                              hint: AppStrings.reasonsFieldHint,
                              maxLength: 50,
                            ),
                          ),
                          if (!(isOnly && isEmpty)) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onRemove(i),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // 추가 버튼
                  GestureDetector(
                    onTap: onAdd,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: labelColor),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.reasonsAddButton,
                          style: TextStyle(
                            fontSize: 12,
                            color: labelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ── 선택형 칩 (scale 애니 + checkmark) ──────────────────────────

class _SelectableChip extends StatefulWidget {
  const _SelectableChip({
    required this.text,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<_SelectableChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1,
    );
    _scale = Tween(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ctrl.reverse();
    widget.onTap();
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? widget.color.withValues(alpha: 0.18)
                : widget.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? widget.color.withValues(alpha: 0.7)
                  : widget.color.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: selected
                    ? Padding(
                        key: const ValueKey('check'),
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.check_rounded,
                            size: 12, color: widget.color),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 비율 바 ────────────────────────────────────────────────────

class _RatioBar extends StatelessWidget {
  const _RatioBar({
    required this.buyCount,
    required this.resistCount,
    required this.colors,
  });

  final int buyCount;
  final int resistCount;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final total = buyCount + resistCount;
    final buyRatio = total == 0 ? 0.5 : buyCount / total;
    final String label;
    if (buyCount == resistCount) {
      label = AppStrings.reasonsRatioEqual;
    } else if (buyCount > resistCount) {
      label = AppStrings.reasonsRatioBuyMore;
    } else {
      label = AppStrings.reasonsRatioResistMore;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_rounded, size: 12, color: AppColors.accent),
            const SizedBox(width: 2),
            Text(
              '$buyCount',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                        height: 6,
                        color: AppColors.green.withValues(alpha: 0.25)),
                    FractionallySizedBox(
                      widthFactor: buyRatio,
                      child: Container(
                          height: 6,
                          color: AppColors.accent.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.remove_rounded, size: 12, color: AppColors.green),
            const SizedBox(width: 2),
            Text(
              '$resistCount',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: colors.textTertiary)),
      ],
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
            AppStrings.cardEditTitle,
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
                  : const Text(AppStrings.cardEditSubmit, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
