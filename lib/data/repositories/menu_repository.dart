import '../models/category.dart';
import '../models/menu_item.dart';
import '../supabase_client.dart';

/// Menu data: categories and their items.
class MenuRepository {
  Future<List<Category>> fetchCategories() async {
    final rows = await supabase
        .from('categories')
        .select()
        .order('sort_order');
    return rows
        .map(Category.fromMap)
        .toList();
  }

  Future<List<MenuItem>> fetchMenuItems() async {
    final rows = await supabase
        .from('menu_items')
        .select()
        .order('sort_order');
    return rows
        .map(MenuItem.fromMap)
        .toList();
  }

  // --- Admin writes -------------------------------------------------------

  Future<Category> upsertCategory(Category category) async {
    final rows = await supabase
        .from('categories')
        .upsert({...category.toMap(), if (category.id.isNotEmpty) 'id': category.id})
        .select();
    return Category.fromMap(rows.first);
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }

  Future<MenuItem> upsertMenuItem(MenuItem item) async {
    final rows = await supabase
        .from('menu_items')
        .upsert({...item.toMap(), if (item.id.isNotEmpty) 'id': item.id})
        .select();
    return MenuItem.fromMap(rows.first);
  }

  Future<void> deleteMenuItem(String id) async {
    await supabase.from('menu_items').delete().eq('id', id);
  }

  /// Reorders by assigning a new sort_order to each id (in list order).
  Future<void> reorderCategories(List<Category> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      await supabase
          .from('categories')
          .update({'sort_order': i + 1}).eq('id', ordered[i].id);
    }
  }
}
