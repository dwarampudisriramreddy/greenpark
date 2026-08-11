import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category.dart';
import '../../../providers/providers.dart';
import '../../../widgets/error_view.dart';
import 'category_edit_screen.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CategoryEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New category'),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Could not load categories.',
          onRetry: () async => refreshAllContent(ref),
        ),
        data: (cats) {
          final sorted = [...cats]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CategoryRow(
              category: sorted[i],
              isFirst: i == 0,
              isLast: i == sorted.length - 1,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CategoryEditScreen(category: sorted[i])),
              ),
              onDelete: () => _confirmDelete(context, ref, sorted[i]),
              onMove: (dir) => _move(ref, sorted, i, dir),
            ),
          );
        },
      ),
    );
  }

  Future<void> _move(WidgetRef ref, List<Category> sorted, int index, int dir) async {
    final target = index + dir;
    if (target < 0 || target >= sorted.length) return;
    final list = [...sorted];
    final moved = list.removeAt(index);
    list.insert(target, moved);
    // Persist the new order.
    for (var i = 0; i < list.length; i++) {
      await ref.read(menuRepositoryProvider).upsertCategory(
            Category(
              id: list[i].id,
              name: list[i].name,
              description: list[i].description,
              icon: list[i].icon,
              imageUrl: list[i].imageUrl,
              sortOrder: i + 1,
              isActive: list[i].isActive,
            ),
          );
    }
    refreshAllContent(ref);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('"${category.name}" and all its dishes will be removed.'),
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
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(menuRepositoryProvider).deleteCategory(category.id);
      refreshAllContent(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the category')),
        );
      }
    }
  }
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onMove;

  const _CategoryRow({
    required this.category,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                  onPressed: isFirst ? null : () => onMove(-1),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  onPressed: isLast ? null : () => onMove(1),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppText.title.copyWith(fontSize: 14.5)),
                  if (category.description != null)
                    Text(
                      category.description!,
                      style: AppText.bodySmallFor(context).copyWith(fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
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
    );
  }
}
