import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/post.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/skeleton.dart';
import 'post_edit_screen.dart';

class PostsAdminScreen extends ConsumerWidget {
  const PostsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(allPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PostEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New post'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: posts.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 3,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: SkeletonBox(height: 120),
            ),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load posts.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (list) {
            final sorted = [...list]..sort((a, b) {
                final aPub = a.isPublished ? 1 : 0;
                final bPub = b.isPublished ? 1 : 0;
                if (aPub != bPub) return bPub - aPub;
                return (b.publishedAt ?? b.createdAt).compareTo(a.publishedAt ?? a.createdAt);
              });
            if (sorted.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Center(child: Text('No posts yet. Tap + to create one.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PostRow(
                post: sorted[i],
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostEditScreen(post: sorted[i])),
                ),
                onDelete: () => _confirmDelete(context, ref, sorted[i]),
                onTogglePublished: () => _togglePublished(context, ref, sorted[i]),
                onToggleFeatured: () => _toggleFeatured(context, ref, sorted[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _togglePublished(BuildContext context, WidgetRef ref, Post post) async {
    await ref.read(postRepositoryProvider).togglePublished(post);
    refreshAllContent(ref);
  }

  Future<void> _toggleFeatured(BuildContext context, WidgetRef ref, Post post) async {
    await ref.read(postRepositoryProvider).toggleFeatured(post);
    refreshAllContent(ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('"${post.title}" will be permanently removed.'),
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
      await ref.read(postRepositoryProvider).delete(post.id);
      refreshAllContent(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the post')),
        );
      }
    }
  }
}

class _PostRow extends StatelessWidget {
  final Post post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublished;
  final VoidCallback onToggleFeatured;

  const _PostRow({
    required this.post,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublished,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppNetworkImage(
                      url: post.imageUrls.first,
                      width: 70,
                      height: 70,
                    ),
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.brandMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.article_outlined, color: AppColors.brandGreen),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: AppText.title.copyWith(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.category ?? 'Updates'} · ${timeAgo(post.publishedAt ?? post.createdAt)}',
                        style: AppText.bodySmall.copyWith(fontSize: 11.5),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: post.isPublished
                                  ? AppColors.brandMint
                                  : AppColors.line,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              post.isPublished ? 'Published' : 'Draft',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: post.isPublished ? AppColors.vegGreen : AppColors.inkSoft,
                              ),
                            ),
                          ),
                          if (post.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGoldLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7A5D10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.published_with_changes_rounded, size: 18),
                  tooltip: post.isPublished ? 'Unpublish' : 'Publish',
                  onPressed: onTogglePublished,
                  color: AppColors.brandGreen,
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  tooltip: post.isFeatured ? 'Unfeature' : 'Feature',
                  onPressed: onToggleFeatured,
                  color: post.isFeatured ? AppColors.accentGold : AppColors.inkSoft,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  color: AppColors.brandGreen,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                  color: AppColors.accentRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
