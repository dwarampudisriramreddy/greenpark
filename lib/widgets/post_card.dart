import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../data/models/post.dart';
import 'app_network_image.dart';

/// Instagram-style post preview card.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = post.imageUrls.isNotEmpty;
    return Material(
      color: isDark ? const Color(0xFF1B231E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                AppNetworkImage(
                  url: post.imageUrls.first,
                  height: 200,
                  width: double.infinity,
                  borderRadius: 0,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandMint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            post.category ?? 'Updates',
                            style: AppText.label.copyWith(color: AppColors.brandGreen, fontSize: 10.5),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          post.isFeatured ? Icons.auto_awesome : Icons.schedule,
                          size: 14,
                          color: post.isFeatured ? AppColors.accentGold : AppColors.inkSoft,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo(post.publishedAt ?? post.createdAt),
                          style: AppText.bodySmall.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(post.title, style: AppText.headline),
                    if (post.description != null && post.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        post.description!,
                        style: AppText.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Read more',
                      style: AppText.label.copyWith(color: AppColors.brandGreen, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
