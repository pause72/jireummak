import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/ads/interstitial_ad_service.dart';
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
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: items.length + 1,
                itemBuilder: (_, i) {
                  if (i == items.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          '잘 참고 있어요 🌿\n더 추가하고 싶은 게 있다면 72시간 참기 버튼을 눌러보세요',
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
    );
  }

  void _showAddItemSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddItemSheet(ref: ref),
    );
  }
}


class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.ref});

  final WidgetRef ref;

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
    final price = double.tryParse(_priceController.text.trim());

    final nameError = name.isEmpty ? AppStrings.homeItemNameRequired : null;
    final priceError = price == null ? AppStrings.homePriceRequired : null;

    if (nameError != null || priceError != null) {
      setState(() {
        _nameError = nameError;
        _priceError = priceError;
      });
      return;
    }

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

    if (mounted) Navigator.of(context).pop();
    InterstitialAdService.instance.show();
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
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
