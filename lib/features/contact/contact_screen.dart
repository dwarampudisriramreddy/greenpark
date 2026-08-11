import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/launchers.dart';
import '../../providers/providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: info.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: SkeletonBox(height: 480),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load contact details.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (r) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              const _ContactIntro(),
              const SizedBox(height: 20),
              _ContactTile(
                icon: Icons.call_rounded,
                color: AppColors.brandGreen,
                title: 'Call Us',
                subtitle: r.phone ?? '',
                onTap: r.phone == null ? null : () => launchCall(r.phone!),
              ),
              const SizedBox(height: 12),
              _ContactTile(
                icon: Icons.chat_rounded,
                color: const Color(0xFF25D366),
                title: 'WhatsApp',
                subtitle: r.whatsapp ?? '',
                onTap: r.whatsapp == null
                    ? null
                    : () => launchWhatsApp(
                          r.whatsapp!,
                          message: 'Hello Green Park! I have a question.',
                        ),
              ),
              const SizedBox(height: 12),
              _ContactTile(
                icon: Icons.navigation_rounded,
                color: const Color(0xFF4285F4),
                title: 'Get Directions',
                subtitle: 'Rajanagaram, Rajahmundry',
                onTap: () => launchDirections(r.mapsUrl),
              ),
              const SizedBox(height: 12),
              _ContactTile(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFE1306C),
                title: 'Instagram',
                subtitle: '@greenparkrestaurant',
                onTap: r.instagramUrl == null
                    ? null
                    : () => launchUrlExternal(r.instagramUrl!),
              ),
              const SizedBox(height: 12),
              _ContactTile(
                icon: Icons.thumb_up_alt_rounded,
                color: const Color(0xFF1877F2),
                title: 'Facebook',
                subtitle: 'greenparkrestaurant',
                onTap: r.facebookUrl == null
                    ? null
                    : () => launchUrlExternal(r.facebookUrl!),
              ),
              if (r.email != null && r.email!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ContactTile(
                  icon: Icons.mail_rounded,
                  color: const Color(0xFF9C27B0),
                  title: 'Email',
                  subtitle: r.email!,
                  onTap: () => launchEmail(r.email!),
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'We look forward to serving you!',
                  style: AppText.subtitleFor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactIntro extends StatelessWidget {
  const _ContactIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text('Get in touch', style: AppText.headline.copyWith(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            'Call us for table bookings, party reservations or any questions.',
            style: AppText.bodySmallFor(context).copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.headline.copyWith(fontSize: 15.5)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.bodySmallFor(context)),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppText.softColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
