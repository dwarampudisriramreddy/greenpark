import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Full-width error state with retry.
class ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.accentRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.accentRed, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for a section with no content.
class EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyView({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.brandGreen.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
