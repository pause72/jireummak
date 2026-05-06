import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/ads/rewarded_ad_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/local/wish_image_local_store.dart';
import '../providers/wish_item_provider.dart';
import '../widgets/empty_waiting_state.dart';
import '../widgets/wish_item_card.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(waitingItemsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: _AddFab(onTap: () => _showAddItemSheet(context, ref)),
      body: SafeArea(
        child: items.isEmpty
            ? const EmptyWaitingState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Text(
                      AppStrings.homeWaitingCount(items.length),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: items.length + 1,
                itemBuilder: (_, i) {
                  if (i == items.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          AppStrings.homeWaitingFooter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textTertiary,
                            height: 1.7,
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WishItemCard(item: items[i], isFirst: i == 0),
                  );
                },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static const _freeSlots = 3;

  void _showAddItemSheet(BuildContext context, WidgetRef ref) {
    final items = ref.read(waitingItemsProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (items.length < _freeSlots) {
      _openSheet(context, ref, messenger);
    } else {
      _showAdGateDialog(context, ref, messenger);
    }
  }

  void _openSheet(BuildContext context, WidgetRef ref, ScaffoldMessengerState messenger) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddItemSheet(
        ref: ref,
        onCompleted: () => _showSuccessSnackbar(messenger),
      ),
    );
  }

  void _showSuccessSnackbar(ScaffoldMessengerState messenger) {
    final msg = AppStrings.motivationalMessages[Random().nextInt(AppStrings.motivationalMessages.length)];
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text(AppStrings.homeSuccessSnackbarTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _showAdGateDialog(BuildContext context, WidgetRef ref, ScaffoldMessengerState messenger) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_outline_rounded, color: AppColors.accent, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.homeSlotFullTitle,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.homeSlotFullBody(_freeSlots),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _watchAdAndAdd(context, ref, messenger);
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text(AppStrings.homeWatchAdButton, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppStrings.cancel, style: TextStyle(fontSize: 14, color: colors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }

  void _watchAdAndAdd(BuildContext context, WidgetRef ref, ScaffoldMessengerState messenger) {
    RewardedAdService.instance.show(
      onRewarded: () {
        if (!context.mounted) return;
        _openSheet(context, ref, messenger);
      },
      onNotAvailable: () {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(AppStrings.homeAdNotReady),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      },
    );
  }
}


class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.ref, this.onCompleted});

  final WidgetRef ref;
  final VoidCallback? onCompleted;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _reasonController = TextEditingController();
  final _picker = ImagePicker();

  String? _nameError;
  String? _priceError;
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (file != null && mounted) setState(() => _pickedImage = file);
  }

  void _showImageSourceDialog() {
    final colors = context.colors;
    final cameraAvailable = _picker.supportsImageSource(ImageSource.camera);

    // dialog가 선택된 source를 반환하면, 닫힌 후에 picker를 호출
    showDialog<ImageSource>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cameraAvailable)
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
                title: Text(AppStrings.homeImagePickerCamera, style: TextStyle(color: colors.textPrimary)),
                onTap: () => Navigator.of(dialogCtx).pop(ImageSource.camera),
              ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colors.textPrimary),
              title: Text(AppStrings.homeImagePickerGallery, style: TextStyle(color: colors.textPrimary)),
              onTap: () => Navigator.of(dialogCtx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    ).then((source) {
      if (source != null) _pickImage(source);
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', ''));

    final nameError = name.isEmpty ? AppStrings.homeItemNameRequired : null;
    final priceError = price == null ? AppStrings.homePriceRequired : null;

    if (nameError != null || priceError != null) {
      setState(() {
        _nameError = nameError;
        _priceError = priceError;
      });
      return;
    }

    // 확인 단계
    if (!mounted) return;
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.homeConfirmTitle,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
            ),
            if (price != null) ...[
              const SizedBox(height: 2),
              Text(
                '₩ ${_formatComma(price.toInt())}원',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              AppStrings.homeConfirmBody,
              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.homeConfirmButton, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final itemId = DateTime.now().millisecondsSinceEpoch.toString();

    if (_pickedImage != null) {
      try {
        await WishImageLocalStore.save(itemId, _pickedImage!);
      } catch (_) {
        // image save failure is non-critical
      }
    }

    final reason = _reasonController.text.trim();
    widget.ref.read(wishItemNotifierProvider.notifier).addItem(
          id: itemId,
          name: name,
          price: price,
          reason: reason.isNotEmpty ? reason : null,
        );

    widget.onCompleted?.call();
    if (mounted) Navigator.of(context).pop();
  }

  static String _formatComma(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
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
            AppStrings.homeAddSheetTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _Field(
            controller: _nameController,
            hint: AppStrings.homeItemNameHint,
            autofocus: true,
            maxLength: 20,
            errorText: _nameError,
            onChanged: (_) { if (_nameError != null) setState(() => _nameError = null); },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _priceController,
            hint: AppStrings.homePriceHint,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PriceCommaFormatter(),
            ],
            prefixText: '₩  ',
            errorText: _priceError,
            onChanged: (_) { if (_priceError != null) setState(() => _priceError = null); },
          ),
          const SizedBox(height: 12),
          _Field(
            controller: _reasonController,
            hint: AppStrings.homeReasonHint,
            maxLength: 30,
          ),
          const SizedBox(height: 16),
          _ImagePickerField(
            pickedImage: _pickedImage,
            onPickTap: _showImageSourceDialog,
            onRemove: () => setState(() => _pickedImage = null),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      AppStrings.homeStartButton,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.pickedImage,
    required this.onPickTap,
    required this.onRemove,
  });

  final XFile? pickedImage;
  final VoidCallback onPickTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (pickedImage != null) {
      // Preview with remove button
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(pickedImage!.path),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    // Empty picker button
    return GestureDetector(
      onTap: onPickTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 20, color: colors.inactive),
            const SizedBox(width: 8),
            Text(
              AppStrings.homeImagePickerLabel,
              style: TextStyle(fontSize: 14, color: colors.inactive),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.prefixText,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: colors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.inactive),
        prefixText: prefixText,
        prefixStyle: TextStyle(fontSize: 15, color: colors.textSecondary),
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: hasError ? AppColors.red.withValues(alpha: 0.05) : colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hasError ? const BorderSide(color: AppColors.red) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hasError ? const BorderSide(color: AppColors.red) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hasError
              ? const BorderSide(color: AppColors.red)
              : const BorderSide(color: AppColors.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterStyle: TextStyle(fontSize: 11, color: colors.textTertiary),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final fabGradient = isDark
        ? [AppColors.green, const Color(0xFF28A372)]
        : [AppColors.accent, const Color(0xFF2D6FD4)];
    final shadowColor = isDark ? AppColors.green : AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: fabGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              AppStrings.homeFabLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceCommaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(',', '');
    if (digits.isEmpty) return newVal.copyWith(text: '');
    final n = int.tryParse(digits);
    if (n == null) return old;
    final formatted = _addCommas(n.toString());
    return newVal.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String s) {
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
