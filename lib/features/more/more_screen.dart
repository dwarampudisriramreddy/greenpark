import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/skeleton.dart';
import '../about/about_screen.dart';
import '../admin/login/admin_login_screen.dart';
import '../contact/contact_screen.dart';
import '../feedback/feedback_screen.dart';
import '../gallery/gallery_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          info.maybeWhen(
            data: (r) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1B231E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  AppLogo(logoUrl: r.logoUrl, size: 64),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: AppText.headline),
                        const SizedBox(height: 4),
                        Text('Rajanagaram · Rajahmundry', style: AppText.subtitleFor(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            orElse: () => const SkeletonBox(height: 100),
          ),
          const SizedBox(height: 20),
          const _AppearanceCard(),
          const SizedBox(height: 8),
          _MoreTile(
            icon: Icons.photo_library_rounded,
            color: AppColors.brandGreen,
            title: 'Gallery',
            subtitle: 'Photos of our food & restaurant',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GalleryScreen()),
            ),
          ),
          _MoreTile(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF0288D1),
            title: 'About Us',
            subtitle: 'Our story, hours & location',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          _MoreTile(
            icon: Icons.headset_mic_rounded,
            color: const Color(0xFFE1306C),
            title: 'Contact',
            subtitle: 'Call, WhatsApp & directions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactScreen()),
            ),
          ),
          _MoreTile(
            icon: Icons.forum_rounded,
            color: AppColors.brandGreen,
            title: 'Give Feedback',
            subtitle: 'Share a review, complaint or suggestion',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.line.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          _MoreTile(
            icon: Icons.admin_panel_settings_rounded,
            color: AppColors.brandGreenDark,
            title: 'Restaurant Admin',
            subtitle: 'Manage menu, offers & content',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
            showChevron: false,
            trailing: Icon(Icons.lock_outline_rounded, size: 18, color: AppText.softColor(context)),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;
  final Widget? trailing;

  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.title.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.bodySmallFor(context)),
                  ],
                ),
              ),
              ?trailing,
              if (showChevron)
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

/// Light / Dark / System appearance picker.
class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B231E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A5D10).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.brightness_6_rounded,
                  color: Color(0xFF7A5D10),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Appearance', style: AppText.title.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('Auto'),
                ),
              ],
              selected: {mode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).setMode(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}
