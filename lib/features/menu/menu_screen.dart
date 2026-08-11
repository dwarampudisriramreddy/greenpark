import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category.dart';
import '../../data/models/menu_item.dart';
import '../../providers/providers.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/error_view.dart';
import '../../widgets/menu/menu_item_detail_sheet.dart';
import '../../widgets/menu/menu_tile.dart';
import '../../widgets/skeleton.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? _categoryId;
  String _query = '';
  int _filter = 0; // 0 all, 1 veg, 2 non-veg
  bool _spicyOnly = false;
  bool _bestsellerOnly = false;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final items = ref.watch(menuItemsProvider);

    final cats = categories.maybeWhen(data: (c) => c, orElse: () => <Category>[]);
    if (_categoryId == null && cats.isNotEmpty) {
      _categoryId = cats.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Menu'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: Column(
          children: [
            _searchAndFilters(context),
            _categoryTabs(categories, cats),
            const SizedBox(height: 6),
            Expanded(
              child: items.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 5,
                  itemBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: SkeletonBox(height: 118),
                  ),
                ),
                error: (e, _) => ErrorView(
                  message: 'We could not load the menu. Please check your connection.',
                  onRetry: () async => refreshAllContent(ref),
                ),
                data: (all) => _buildList(cats, all),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search biryani, paneer, curry…',
              prefixIcon: Icon(Icons.search_rounded, color: AppText.softColor(context)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => setState(() => _query = ''),
                    )
                  : null,
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == 0,
                  icon: Icons.restaurant_menu_rounded,
                  onTap: () => setState(() => _filter = 0),
                ),
                _FilterChip(
                  label: 'Veg',
                  selected: _filter == 1,
                  icon: Icons.eco_rounded,
                  onTap: () => setState(() => _filter = 1),
                ),
                _FilterChip(
                  label: 'Non-veg',
                  selected: _filter == 2,
                  icon: Icons.egg_alt_rounded,
                  onTap: () => setState(() => _filter = 2),
                ),
                _FilterChip(
                  label: 'Spicy',
                  selected: _spicyOnly,
                  icon: Icons.local_fire_department_rounded,
                  onTap: () => setState(() => _spicyOnly = !_spicyOnly),
                ),
                _FilterChip(
                  label: 'Bestseller',
                  selected: _bestsellerOnly,
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => setState(() => _bestsellerOnly = !_bestsellerOnly),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTabs(AsyncValue<List<Category>> categories, List<Category> cats) {
    return SizedBox(
      height: 58,
      child: categories.when(
        loading: () => const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (_) {
          if (cats.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = cats[i];
              final selected = c.id == _categoryId;
              return GestureDetector(
                onTap: () => setState(() => _categoryId = c.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.brandGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.brandGreen : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcon(c.icon),
                        size: 16,
                        color: selected ? Colors.white : AppColors.brandGreen,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        c.name,
                        style: AppText.title.copyWith(
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildList(List<Category> cats, List<MenuItem> all) {
    var items = all.where((m) => m.categoryId == _categoryId).toList();
    if (_query.isNotEmpty) {
      items = items.where((m) => m.name.toLowerCase().contains(_query)).toList();
    }
    if (_filter == 1) items = items.where((m) => m.isVeg).toList();
    if (_filter == 2) items = items.where((m) => !m.isVeg).toList();
    if (_spicyOnly) items = items.where((m) => m.isSpicy).toList();
    if (_bestsellerOnly) items = items.where((m) => m.isBestseller).toList();
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(
                  _query.isNotEmpty ? Icons.search_off_rounded : Icons.restaurant_menu,
                  size: 52,
                  color: AppColors.green(context),
                ),
                const SizedBox(height: 12),
                Text(
                  _query.isNotEmpty ? 'No dishes match your search' : 'No dishes here yet',
                  style: AppText.headline,
                ),
                const SizedBox(height: 4),
                Text(
                  'Try a different category or search term.',
                  style: AppText.subtitleFor(context),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final catName = cats.firstWhere((c) => c.id == _categoryId, orElse: () => cats.first).name;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          '${items.length} ${items.length == 1 ? 'dish' : 'dishes'} · $catName',
          style: AppText.bodySmallFor(context),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MenuTile(
              item: item,
              onTap: () => _showDetail(item),
            ),
          ),
      ],
    );
  }

  void _showDetail(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuItemDetailSheet(item: item),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandMint : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.brandGreen : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? AppColors.brandGreen
                  : AppText.softColor(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.title.copyWith(
                fontSize: 12.5,
                color: selected
                    ? AppColors.brandGreen
                    : AppText.softColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
