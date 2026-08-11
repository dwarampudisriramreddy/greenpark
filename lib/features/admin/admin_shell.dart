import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../more/more_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'feedback/feedback_admin_screen.dart';
import 'gallery/gallery_admin_screen.dart';
import 'info/restaurant_info_edit_screen.dart';
import 'menu/menu_admin_screen.dart';
import 'offers/offers_admin_screen.dart';
import 'posts/posts_admin_screen.dart';
import 'profile/profile_screen.dart';

/// Admin workspace shell with a side navigation drawer.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  static const _titles = [
    'Dashboard',
    'Menu Management',
    'Offers Management',
    'Posts Management',
    'Gallery Management',
    'Feedback Inbox',
    'Restaurant Info',
    'Profile',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.menu_book_outlined,
    Icons.local_offer_outlined,
    Icons.article_outlined,
    Icons.photo_library_outlined,
    Icons.forum_outlined,
    Icons.storefront_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final name = ref.watch(authRepositoryProvider).adminName();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'View customer app',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoreScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.brandMint,
                      child: const Icon(Icons.storefront_rounded, color: AppColors.brandGreen, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Text('Green Park Admin', style: AppText.headline),
                    const SizedBox(height: 2),
                    FutureBuilder<String?>(
                      future: name,
                      builder: (context, snapshot) => Text(
                        snapshot.data ?? '',
                        style: AppText.bodySmallFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _titles.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(_icons[i], color: i == _index ? AppColors.brandGreen : null),
                    title: Text(_titles[i]),
                    selected: i == _index,
                    selectedColor: AppColors.brandGreen,
                    selectedTileColor: AppColors.brandMint.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      setState(() => _index = i);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    refreshAllContent(ref);
                    if (context.mounted) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isAdmin.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Authorization check failed')),
        data: (authorized) {
          if (!authorized) {
            return const Center(child: Text('You are not authorized to view the admin panel.'));
          }
          switch (_index) {
            case 0:
              return const DashboardScreen();
            case 1:
              return const MenuAdminScreen();
            case 2:
              return const OffersAdminScreen();
            case 3:
              return const PostsAdminScreen();
            case 4:
              return const GalleryAdminScreen();
            case 5:
              return const FeedbackAdminScreen();
            case 6:
              return const RestaurantInfoEditScreen();
            case 7:
              return const ProfileScreen();
            default:
              return const DashboardScreen();
          }
        },
      ),
    );
  }
}
