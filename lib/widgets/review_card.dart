import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/feedback_review.dart';

/// One published customer review (star rating + message).
class ReviewCard extends StatelessWidget {
  final FeedbackReview review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(review.customerName);
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B231E)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brandMint,
                child: Text(
                  initials,
                  style: AppText.label.copyWith(color: AppColors.brandGreen),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.customerName?.isEmpty ?? true
                      ? 'Green Park Guest'
                      : review.customerName!,
                  style: AppText.title.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.format_quote_rounded, color: AppColors.brandMint),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 17,
                  color: i <= review.rating
                      ? AppColors.accentGold
                      : AppText.softColor(context),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              review.message,
              style: AppText.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _prettyDate(review.createdAt),
            style: AppText.bodySmallFor(context).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'GP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _prettyDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays <= 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day} ${_months[date.month - 1]}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}
