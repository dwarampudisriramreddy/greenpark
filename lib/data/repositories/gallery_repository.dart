import '../models/gallery_image.dart';
import '../supabase_client.dart';

/// Restaurant photo gallery.
class GalleryRepository {
  Future<List<GalleryImage>> fetch() async {
    final rows = await supabase
        .from('gallery_images')
        .select()
        .order('sort_order');
    return rows.map(GalleryImage.fromMap).toList();
  }

  Future<List<String>> fetchCategories() async {
    final images = await fetch();
    return images.map((g) => g.category).whereType<String>().toSet().toList();
  }

  Future<GalleryImage> upsert(GalleryImage image) async {
    final rows = await supabase
        .from('gallery_images')
        .upsert({...image.toMap(), if (image.id.isNotEmpty) 'id': image.id})
        .select();
    return GalleryImage.fromMap(rows.first);
  }

  Future<void> delete(String id) async {
    await supabase.from('gallery_images').delete().eq('id', id);
  }

  Future<void> togglePublished(GalleryImage image) async {
    await supabase
        .from('gallery_images')
        .update({'is_published': !image.isPublished}).eq('id', image.id);
  }

  Future<void> reorder(List<GalleryImage> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      await supabase
          .from('gallery_images')
          .update({'sort_order': i + 1}).eq('id', ordered[i].id);
    }
  }
}
