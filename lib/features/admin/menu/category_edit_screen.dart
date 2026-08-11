import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../providers/providers.dart';
import '../../../widgets/category_icon.dart';

class CategoryEditScreen extends ConsumerStatefulWidget {
  final Category? category;
  const CategoryEditScreen({super.key, this.category});

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  static const _icons = [
    'tapas', 'soup', 'rice', 'ramen', 'curry', 'grill',
    'chinese', 'veg', 'nonveg', 'dessert', 'cafe',
  ];

  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late final _description =
      TextEditingController(text: widget.category?.description ?? '');
  late String? _icon = widget.category?.icon ?? 'tapas';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(menuRepositoryProvider).upsertCategory(Category(
            id: widget.category?.id ?? '',
            name: name,
            description: _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            icon: _icon,
            imageUrl: widget.category?.imageUrl,
            sortOrder: widget.category?.sortOrder ?? 0,
            isActive: widget.category?.isActive ?? true,
          ));
      refreshAllContent(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.category == null ? 'Category created' : 'Category updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the category')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'New Category' : 'Edit Category'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Short description (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Text('Icon', style: AppText.headline.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final icon in _icons)
                GestureDetector(
                  onTap: () => setState(() => _icon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _icon == icon
                          ? AppColors.brandGreen
                          : Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1B231E)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _icon == icon ? AppColors.brandGreen : AppColors.line,
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      categoryIcon(icon),
                      color: _icon == icon ? Colors.white : AppColors.inkSoft,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save category'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ],
      ),
    );
  }
}
