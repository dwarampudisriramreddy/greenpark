import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/post_card.dart';
import '../../widgets/skeleton.dart';
import 'post_detail_screen.dart';

class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: posts.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 4,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonBox(height: 280),
            ),
          ),
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 220,
                child: ErrorView(
                  message: 'Could not load updates. Pull to refresh.',
                  onRetry: () async => refreshAllContent(ref),
                ),
              ),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_outlined, size: 52, color: AppColors.brandGreen),
                          SizedBox(height: 12),
                          Text('No updates yet'),
                          SizedBox(height: 4),
                          Text('Follow us for the latest news!'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            final sorted = [...list]..sort((a, b) {
                final at = a.publishedAt ?? a.createdAt;
                final bt = b.publishedAt ?? b.createdAt;
                return bt.compareTo(at);
              });
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                for (final post in sorted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PostCard(
                      post: post,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: post.id, initial: post),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
