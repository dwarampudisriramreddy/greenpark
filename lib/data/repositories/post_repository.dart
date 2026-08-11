import '../models/post.dart';
import '../supabase_client.dart';

/// Posts / updates, including their multi-image attachments.
class PostRepository {
  Future<List<Post>> fetch() async {
    final rows = await supabase
        .from('posts')
        .select()
        .order('published_at', ascending: false);

    final posts = rows
        .map(Post.fromMap)
        .toList();
    if (posts.isEmpty) return posts;

    final postIds = posts.map((p) => p.id).toList();
    final imageRows = await supabase
        .from('post_images')
        .select('post_id, image_url, sort_order')
        .inFilter('post_id', postIds)
        .order('sort_order');

    final imagesByPost = <String, List<String>>{};
    for (final row in imageRows as List<dynamic>) {
      final map = row as Map<String, dynamic>;
      imagesByPost.putIfAbsent(map['post_id'] as String, () => [])
          .add(map['image_url'] as String);
    }
    return [
      for (final p in posts)
        Post(
          id: p.id,
          title: p.title,
          description: p.description,
          category: p.category,
          isFeatured: p.isFeatured,
          isPublished: p.isPublished,
          publishedAt: p.publishedAt,
          createdAt: p.createdAt,
          imageUrls: imagesByPost[p.id] ?? const [],
        ),
    ];
  }

  /// Convenience list without attachments (used by the admin list).
  Future<List<Post>> fetchFlat() async {
    final rows = await supabase
        .from('posts')
        .select()
        .order('published_at', ascending: false);
    return rows
        .map(Post.fromMap)
        .toList();
  }

  Future<Post> upsert(Post post) async {
    final rows = await supabase
        .from('posts')
        .upsert({...post.toMap(), if (post.id.isNotEmpty) 'id': post.id})
        .select();
    return Post.fromMap(rows.first);
  }

  Future<void> delete(String id) async {
    await supabase.from('post_images').delete().eq('post_id', id);
    await supabase.from('posts').delete().eq('id', id);
  }

  Future<void> setImages(String postId, List<String> urls) async {
    await supabase.from('post_images').delete().eq('post_id', postId);
    if (urls.isEmpty) return;
    await supabase.from('post_images').insert([
      for (var i = 0; i < urls.length; i++)
        {'post_id': postId, 'image_url': urls[i], 'sort_order': i + 1},
    ]);
  }

  Future<void> togglePublished(Post post) async {
    await supabase
        .from('posts')
        .update({'is_published': !post.isPublished}).eq('id', post.id);
  }

  Future<void> toggleFeatured(Post post) async {
    await supabase
        .from('posts')
        .update({'is_featured': !post.isFeatured}).eq('id', post.id);
  }
}
