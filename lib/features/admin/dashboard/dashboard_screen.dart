import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../../widgets/skeleton.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final info = ref.watch(restaurantInfoProvider);

    return RefreshIndicator(
      onRefresh: () async => refreshAllContent(ref),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandGreen, AppColors.brandGreenDark],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Text('Welcome back', style: AppText.headline.copyWith(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  info.maybeWhen(data: (r) => r.name, orElse: () => 'Green Park'),
                  style: AppText.displaySmall.copyWith(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here is what is live on your customer app.',
                  style: AppText.bodySmallFor(context).copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          stats.when(
            loading: () => const Column(
              children: [
                SkeletonBox(height: 150),
                SizedBox(height: 14),
                SkeletonBox(height: 90),
              ],
            ),
            error: (e, _) => const Center(child: Text('Could not load statistics')),
            data: (s) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF0288D1),
                        label: 'Menu items',
                        value: '${s.menuItems}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_offer_rounded,
                        color: const Color(0xFFE1306C),
                        label: 'Active offers',
                        value: '${s.activeOffers}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.article_rounded,
                        color: AppColors.accentGold,
                        label: 'Published posts',
                        value: '${s.publishedPosts}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.photo_library_rounded,
                        color: AppColors.brandGreen,
                        label: 'Gallery images',
                        value: '${s.galleryImages}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _QuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppText.displayMedium.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppText.bodySmallFor(context)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenSurface(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick tips', style: AppText.headline.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          _tip(context, Icons.bolt_rounded, 'Expired offers are hidden automatically from customers.'),
          _tip(context, Icons.image_outlined, 'Use the side menu to upload images for every dish.'),
          _tip(context, Icons.published_with_changes_rounded, 'Changes appear in the app instantly.'),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.green(context)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppText.bodySmallFor(context))),
        ],
      ),
    );
  }
}
