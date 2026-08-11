import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A section heading with an optional trailing action used across home screen.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String? viewAllLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.viewAllLabel = 'View all',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AccentBar(),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(foregroundColor: AppColors.brandGreen),
            child: Text(viewAllLabel!),
          ),
      ],
    );
  }
}

class _AccentBar extends StatelessWidget {
  const _AccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 3.5,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 7,
          height: 3.5,
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
