import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../data/models/menu_item.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';

class MenuItemEditScreen extends ConsumerStatefulWidget {
  final MenuItem? item;
  final String? categoryId;

  const MenuItemEditScreen({super.key, this.item, this.categoryId});

  @override
  ConsumerState<MenuItemEditScreen> createState() => _MenuItemEditScreenState();
}

class _MenuItemEditScreenState extends ConsumerState<MenuItemEditScreen> {
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _description =
      TextEditingController(text: widget.item?.description ?? '');
  late final _price = TextEditingController(
    text: widget.item?.price != null
        ? widget.item!.price.toStringAsFixed(widget.item!.price == widget.item!.price.roundToDouble() ? 0 : 2)
        : '',
  );

  late String? _categoryId = widget.item?.categoryId ?? widget.categoryId;
  late bool _isVeg = widget.item?.isVeg ?? true;
  late bool _isSpicy = widget.item?.isSpicy ?? false;
  late bool _isBestseller = widget.item?.isBestseller ?? false;
  late bool _isAvailable = widget.item?.isAvailable ?? true;
  late bool _isActive = widget.item?.isActive ?? true;

  String? _existingImageUrl;
  File? _pickedImage;
  bool _uploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = widget.item?.imageUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim());
    if (name.isEmpty) {
      _snack('Dish name is required');
      return;
    }
    if (price == null || price <= 0) {
      _snack('Enter a valid price');
      return;
    }
    if (_categoryId == null) {
      _snack('Choose a category');
      return;
    }
    setState(() => _saving = true);
    try {
      String? imageUrl = _existingImageUrl;

      if (_pickedImage != null) {
        setState(() => _uploading = true);
        imageUrl = await ref.read(storageRepositoryProvider).uploadImage(
              bucket: AppConfig.bucketMenuImages,
              file: _pickedImage!,
              prefix: 'dishes',
            );
      }

      await ref.read(menuRepositoryProvider).upsertMenuItem(MenuItem(
            id: widget.item?.id ?? '',
            categoryId: _categoryId,
            name: name,
            description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            price: price,
            imageUrl: imageUrl,
            isVeg: _isVeg,
            isSpicy: _isSpicy,
            isBestseller: _isBestseller,
            isAvailable: _isAvailable,
            isActive: _isActive,
            sortOrder: widget.item?.sortOrder ?? 0,
          ));

      refreshAllContent(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.item == null ? 'Dish added to menu' : 'Dish updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) _snack('Could not save the dish');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final cats = categories.maybeWhen(data: (c) => c, orElse: () => <Category>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New Dish' : 'Edit Dish'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Image picker
          Center(
            child: GestureDetector(
              onTap: _uploading ? null : _pickImage,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            width: 220,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : AppNetworkImage(
                            url: _existingImageUrl,
                            width: 220,
                            height: 150,
                            borderRadius: 18,
                            fallbackLabel: 'No image',
                          ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.brandGreen,
                        shape: BoxShape.circle,
                      ),
                      child: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Tap to choose a photo',
              style: AppText.bodySmall,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Dish name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price (₹)',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _categoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in cats)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),

          Text('Flags', style: AppText.headline.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          SwitchListTile(
            value: _isVeg,
            onChanged: (v) => setState(() => _isVeg = v),
            title: const Text('Vegetarian'),
            subtitle: const Text('Mark as pure veg'),
            activeThumbColor: AppColors.vegGreen,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isSpicy,
            onChanged: (v) => setState(() => _isSpicy = v),
            title: const Text('Spicy'),
            subtitle: const Text('Show a spicy indicator'),
            activeThumbColor: AppColors.accentRed,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isBestseller,
            onChanged: (v) => setState(() => _isBestseller = v),
            title: const Text('Bestseller'),
            subtitle: const Text('Featured on the home screen'),
            activeThumbColor: AppColors.accentGold,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isAvailable,
            onChanged: (v) => setState(() => _isAvailable = v),
            title: const Text('Available'),
            subtitle: const Text('Turn off to mark as sold out'),
            activeThumbColor: AppColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            title: const Text('Visible to customers'),
            subtitle: const Text('Hide to keep on menu but not show it'),
            activeThumbColor: AppColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save dish'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
