import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../data/models/restaurant_info.dart';
import '../../providers/providers.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: info.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              SkeletonBox(height: 130),
              SizedBox(height: 20),
              SkeletonBox(height: 180),
              SizedBox(height: 20),
              SkeletonBox(height: 220),
            ],
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load restaurant information.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (r) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _brandHeader(context, r),
              const SizedBox(height: 24),
              _aboutCard(context, r),
              const SizedBox(height: 24),
              _hoursCard(context, r),
              const SizedBox(height: 24),
              _locationCard(context, r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandHeader(BuildContext context, RestaurantInfo r) {
    return Column(
      children: [
        AppLogo(logoUrl: r.logoUrl, size: 92),
        const SizedBox(height: 16),
        Text(r.name, style: AppText.displayMedium, textAlign: TextAlign.center),
        if (r.tagline != null && r.tagline!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(r.tagline!, style: AppText.subtitle, textAlign: TextAlign.center),
        ],
      ],
    );
  }

  Widget _aboutCard(BuildContext context, RestaurantInfo r) {
    return _Card(
      icon: Icons.auto_stories_rounded,
      title: 'Our Story',
      child: Text(
        r.about ?? 'A family restaurant serving authentic Andhra and multi-cuisine dishes.',
        style: AppText.body.copyWith(height: 1.7),
      ),
    );
  }

  Widget _hoursCard(BuildContext context, RestaurantInfo r) {
    final order = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
    ];
    final labels = {
      'monday': 'Monday', 'tuesday': 'Tuesday', 'wednesday': 'Wednesday',
      'thursday': 'Thursday', 'friday': 'Friday', 'saturday': 'Saturday', 'sunday': 'Sunday',
    };
    final rows = order
        .where((d) => r.openingHours.containsKey(d))
        .map((d) {
          final h = r.openingHours[d]!;
          final hours = '${formatTime(h['open'] ?? '')} - ${formatTime(h['close'] ?? '')}';
          return _hoursRow(labels[d]!, hours);
        })
        .toList();
    if (rows.isEmpty) {
      rows.add(_hoursRow('Open daily', '11:00 AM - 11:00 PM'));
    }
    return _Card(
      icon: Icons.schedule_rounded,
      title: 'Opening Hours',
      child: Column(children: rows),
    );
  }

  Widget _hoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(day, style: AppText.title.copyWith(fontSize: 13.5)),
          ),
          Text(
            hours,
            style: AppText.body.copyWith(
              color: day.toLowerCase() == 'sunday' ? AppColors.accentRed : AppColors.brandGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard(BuildContext context, RestaurantInfo r) {
    return _Card(
      icon: Icons.location_on_rounded,
      title: 'Find Us',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.address ?? 'Rajanagaram, Rajahmundry', style: AppText.body),
          if (r.mapsUrl != null && r.mapsUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => launchDirections(r.mapsUrl),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text('Get Directions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
                side: const BorderSide(color: AppColors.brandGreen),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Card({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B231E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.brandMint, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: AppColors.brandGreen),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppText.headline),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
