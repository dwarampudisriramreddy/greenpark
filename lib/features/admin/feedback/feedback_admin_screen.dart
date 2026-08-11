import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/feedback_review.dart';
import '../../../providers/providers.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/skeleton.dart';

/// Admin inbox: review, publish, or delete customer feedback.
class FeedbackAdminScreen extends ConsumerWidget {
  const FeedbackAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedback = ref.watch(allFeedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Inbox'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: feedback.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 4,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonBox(height: 140),
            ),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load feedback.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (list) {
            final sorted = [...list]..sort((a, b) {
                final aUnpublished = a.isPublished ? 0 : 1;
                final bUnpublished = b.isPublished ? 0 : 1;
                if (aUnpublished != bUnpublished) return bUnpublished - aUnpublished;
                return b.createdAt.compareTo(a.createdAt);
              });
            if (sorted.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Center(child: Text('No feedback yet.')),
                ],
              );
            }
            final unpublished = sorted.where((f) => !f.isPublished).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                if (unpublished > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGoldLight.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unpublished new ${unpublished == 1 ? 'message' : 'messages'} waiting',
                        style: AppText.bodySmallFor(context).copyWith(
                          color: const Color(0xFF7A5D10),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                for (final f in sorted) ...[
                  _FeedbackRow(
                    review: f,
                    onTogglePublish: () => _togglePublish(context, ref, f),
                    onDelete: () => _confirmDelete(context, ref, f),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _togglePublish(BuildContext context, WidgetRef ref, FeedbackReview review) async {
    if (review.kind != FeedbackKind.review) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only reviews can be published to the app.')),
      );
      return;
    }
    await ref.read(feedbackRepositoryProvider).togglePublish(review);
    refreshAllContent(ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FeedbackReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete feedback?'),
        content: const Text('This feedback will be permanently removed.'),
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
      await ref.read(feedbackRepositoryProvider).delete(review.id);
      refreshAllContent(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the feedback')),
        );
      }
    }
  }
}

class _FeedbackRow extends StatelessWidget {
  final FeedbackReview review;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const _FeedbackRow({
    required this.review,
    required this.onTogglePublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (review.kind) {
      FeedbackKind.review => (AppColors.brandGreen, Icons.thumb_up_alt_rounded),
      FeedbackKind.complaint => (AppColors.accentRed, Icons.report_problem_rounded),
      FeedbackKind.suggestion => (AppColors.accentGold, Icons.lightbulb_rounded),
    };
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                review.kind.label,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (review.kind == FeedbackKind.review)
                              for (var i = 1; i <= 5; i++)
                                Icon(
                                  i <= review.rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 15,
                                  color: i <= review.rating
                                      ? AppColors.accentGold
                                      : AppColors.inkSoft,
                                ),
                            const Spacer(),
                            Text(
                              _shortDate(review.createdAt),
                              style: AppText.bodySmallFor(context).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.message,
                          style: AppText.body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (review.customerName != null || review.contact != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (review.customerName != null) review.customerName!,
                              if (review.contact != null) review.contact!,
                            ].join(' · '),
                            style: AppText.bodySmallFor(context).copyWith(fontSize: 11.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    review.isPublished
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  tooltip: review.isPublished
                      ? 'Unpublish from app'
                      : 'Publish to app',
                  onPressed: onTogglePublish,
                  color: review.isPublished ? AppColors.accentGold : AppColors.brandGreen,
                ),
                if (!review.isPublished)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Private',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                const Spacer(),
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

  String _shortDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}
