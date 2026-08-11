import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/post.dart';
import '../../providers/providers.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';

/// Full post read screen with a swipeable image gallery.
class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  final Post initial;

  const PostDetailScreen({super.key, required this.postId, required this.initial});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late Future<Post> _future;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Post> _load() async {
    final repo = ref.read(postRepositoryProvider);
    final all = await repo.fetch();
    for (final p in all) {
      if (p.id == widget.postId) return p;
    }
    return widget.initial;
  }

  Future<void> _retry() async => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Post>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _PostSkeleton();
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: ErrorView(message: 'Could not open this post.', onRetry: _retry),
            );
          }
          return _PostView(
            post: snapshot.data!,
            currentPage: _page,
            onImageChanged: (i) => setState(() => _page = i),
          );
        },
      ),
    );
  }
}

class _PostView extends StatelessWidget {
  final Post post;
  final int currentPage;
  final ValueChanged<int> onImageChanged;
  const _PostView({
    required this.post,
    required this.currentPage,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = post.imageUrls.isNotEmpty;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: hasImages ? 320 : 100,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            post.category ?? 'Updates',
            style: AppText.title.copyWith(fontSize: 14),
          ),
          flexibleSpace: hasImages
              ? FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        onPageChanged: onImageChanged,
                        itemCount: post.imageUrls.length,
                        itemBuilder: (_, i) => AppNetworkImage(
                          url: post.imageUrls[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (post.imageUrls.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${currentPage + 1} / ${post.imageUrls.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : const FlexibleSpaceBar(background: SizedBox.shrink()),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (post.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accentGoldLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Color(0xFF7A5D10),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (post.isFeatured) const SizedBox(width: 10),
                    Icon(Icons.schedule, size: 14, color: AppColors.inkSoft),
                    const SizedBox(width: 5),
                    Text(
                      timeAgo(post.publishedAt ?? post.createdAt),
                      style: AppText.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(post.title, style: AppText.displayMedium),
                if (post.description != null && post.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(post.description!, style: AppText.body.copyWith(fontSize: 15)),
                ],
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Green Park Family Restaurant\nRajanagaram · Rajahmundry',
                    textAlign: TextAlign.center,
                    style: AppText.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SkeletonBox(height: 300, borderRadius: 0)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 18, width: 120),
                SizedBox(height: 16),
                SkeletonBox(height: 28),
                SizedBox(height: 16),
                SkeletonBox(height: 90),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
