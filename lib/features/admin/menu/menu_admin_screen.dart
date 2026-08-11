import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../data/models/menu_item.dart';
import '../../../providers/providers.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/veg_badge.dart';
import '../../../widgets/skeleton.dart';
import 'category_management_screen.dart';
import 'menu_item_edit_screen.dart';

class MenuAdminScreen extends ConsumerStatefulWidget {
  const MenuAdminScreen({super.key});

  @override
  ConsumerState<MenuAdminScreen> createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends ConsumerState<MenuAdminScreen> {
  String? _categoryId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final items = ref.watch(menuItemsProvider);
    final cats = categories.maybeWhen(data: (c) => c, orElse: () => <Category>[]);
    if (_categoryId == null && cats.isNotEmpty) _categoryId = cats.first.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            tooltip: 'Manage categories',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _categoryId == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MenuItemEditScreen(
                      categoryId: _categoryId!,
                    ),
                  ),
                ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add dish'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search dishes…',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.inkSoft),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
              child: categories.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                error: (_, _) => const SizedBox.shrink(),
                data: (_) {
                  if (cats.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = cats[i];
                      final selected = c.id == _categoryId;
                      return GestureDetector(
                        onTap: () => setState(() => _categoryId = c.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.brandGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: selected ? AppColors.brandGreen : AppColors.line),
                          ),
                          child: Center(
                            child: Text(
                              c.name,
                              style: AppText.title.copyWith(
                                fontSize: 12.5,
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 5,
                  itemBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SkeletonBox(height: 84),
                  ),
                ),
                error: (e, _) => ErrorView(
                  message: 'Could not load the menu.',
                  onRetry: () async => refreshAllContent(ref),
                ),
                data: (all) {
                  var filtered = all.where((m) => m.categoryId == _categoryId).toList();
                  if (_query.isNotEmpty) {
                    filtered = filtered.where((m) => m.name.toLowerCase().contains(_query)).toList();
                  }
                  filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.restaurant_menu, size: 46, color: AppColors.brandGreen),
                              const SizedBox(height: 10),
                              Text('No dishes in this category', style: AppText.headline),
                              const SizedBox(height: 6),
                              Text('Tap + Add dish to create one.', style: AppText.subtitleFor(context)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ItemRow(
                      item: filtered[i],
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MenuItemEditScreen(item: filtered[i]),
                        ),
                      ),
                      onDelete: () => _confirmDelete(filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete dish?'),
        content: Text('"${item.name}" will be removed from the menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(menuRepositoryProvider).deleteMenuItem(item.id);
      refreshAllContent(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish deleted')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the dish')),
        );
      }
    }
  }
}

class _ItemRow extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemRow({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              VegBadge(isVeg: item.isVeg),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppText.title.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(
                      '₹${item.price.toStringAsFixed(0)} · ${item.isAvailable ? 'Available' : 'Sold out'}',
                      style: AppText.bodySmallFor(context).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (item.isBestseller)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.auto_awesome, size: 16, color: AppColors.accentGold),
                ),
              if (item.isSpicy)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.local_fire_department, size: 16, color: AppColors.accentRed),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 19),
                onPressed: onEdit,
                color: AppColors.brandGreen,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                onPressed: onDelete,
                color: AppColors.accentRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
