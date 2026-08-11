import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/launchers.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/offer.dart';
import '../../data/models/post.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/menu/menu_item_card.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/post_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton.dart';
import '../gallery/gallery_screen.dart';
import '../menu/menu_screen.dart';
import '../offers/offers_screen.dart';
import '../posts/post_detail_screen.dart';
import '../posts/posts_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider);

    return RefreshIndicator(
      onRefresh: () async => refreshAllContent(ref),
      edgeOffset: 80,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: info.maybeWhen(
                data: (r) => AppLogo(logoUrl: r.logoUrl, size: 40),
                orElse: () => const AppLogo(size: 40),
              ),
            ),
            leadingWidth: 64,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.maybeWhen(data: (r) => r.name, orElse: () => 'Green Park'),
                  style: AppText.displaySmall.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rajanagaram · Rajahmundry',
                  style: AppText.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _buildContent(context, ref)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider);
    final menu = ref.watch(menuItemsProvider);
    final offers = ref.watch(offersProvider);
    final posts = ref.watch(postsProvider);
    final gallery = ref.watch(galleryProvider);

    final featured = menu.maybeWhen(
      data: (items) => items.where((i) => i.isBestseller).take(6).toList(),
      orElse: () => <MenuItem>[],
    );
    final featuredOffers = offers.maybeWhen(
      data: (list) {
        final f = list.where((o) => o.isFeatured).toList();
        return f.isNotEmpty ? f : list.take(3).toList();
      },
      orElse: () => <Offer>[],
    );
    final latestPosts = posts.maybeWhen(
      data: (list) => list.take(3).toList(),
      orElse: () => <Post>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        info.when(
          loading: () => const SkeletonBox(height: 220, borderRadius: 0),
          error: (_, _) => const SizedBox.shrink(),
          data: (r) => HeroBanner(restaurant: r),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: info.when(
            loading: () => const SkeletonBox(height: 120),
            error: (_, _) => const SizedBox.shrink(),
            data: (r) => IntroCard(restaurant: r),
          ),
        ),
        const SizedBox(height: 28),

        // Featured dishes
        _section(
          context,
          title: 'Must-try dishes',
          subtitle: 'Our guests love these',
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          ),
          child: _featuredRow(context, featured, menu),
        ),

        // Offers
        _section(
          context,
          title: 'Special offers',
          subtitle: 'Limited-time deals',
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OffersScreen()),
          ),
          child: offers.when(
            loading: () => const SizedBox(
              height: 210,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featuredOffers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => OfferCard(offer: featuredOffers[i]),
                ),
              );
            },
          ),
        ),

        // Latest posts
        _section(
          context,
          title: 'Latest updates',
          subtitle: 'What\'s happening at Green Park',
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostsScreen()),
          ),
          child: posts.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  for (final p in latestPosts)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: PostCard(
                        post: p,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(postId: p.id, initial: p),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Photo highlights
        _section(
          context,
          title: 'Moments at Green Park',
          onViewAll: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GalleryScreen()),
          ),
          child: gallery.when(
            loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: list.take(8).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final g = list.take(8).toList()[i];
                    return AppNetworkImage(
                      url: g.imageUrl,
                      width: 200,
                      height: 150,
                      borderRadius: 18,
                    );
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
        // Bottom quick actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _bottomActions(context, ref),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onViewAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 12, 14),
          child: SectionHeader(
            title: title,
            subtitle: subtitle,
            onViewAll: onViewAll,
          ),
        ),
        child,
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _featuredRow(
    BuildContext context,
    List<MenuItem> featured,
    AsyncValue<List<MenuItem>> menu,
  ) {
    if (featured.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox.shrink(),
      );
    }
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => MenuItemCard(item: featured[i]),
      ),
    );
  }

  Widget _bottomActions(BuildContext context, WidgetRef ref) {
    final info = ref.watch(restaurantInfoProvider).maybeWhen(
          data: (r) => r,
          orElse: () => null,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Call Now',
                icon: Icons.call_rounded,
                onPressed: () => launchCall(info?.phone ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Directions',
                icon: Icons.navigation_rounded,
                filled: false,
                onPressed: () => launchDirections(info?.mapsUrl),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'View Full Menu',
          icon: Icons.menu_book_rounded,
          expanded: true,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MenuScreen()),
          ),
        ),
      ],
    );
  }
}

class HeroBanner extends StatelessWidget {
  final dynamic restaurant;
  const HeroBanner({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final heroUrl = restaurant?.heroImageUrl as String?;
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: AppNetworkImage(
            url: heroUrl,
            fit: BoxFit.cover,
            fallbackLabel: 'Green Park',
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.72),
              ],
              stops: const [0.2, 0.55, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.park_rounded, color: AppColors.accentGoldLight, size: 26),
              const SizedBox(height: 8),
              Text(
                'GREEN PARK',
                style: AppText.displayMedium.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                restaurant?.tagline ?? 'The Taste of Andhra, in the Heart of Rajahmundry',
                style: AppText.body.copyWith(color: Colors.white.withValues(alpha: 0.92)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.accentGoldLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rajanagaram · Rajahmundry · Andhra Pradesh',
                      style: AppText.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class IntroCard extends StatelessWidget {
  final dynamic restaurant;
  const IntroCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.brandMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_rounded, color: AppColors.brandGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant?.name ?? 'Green Park Family Restaurant',
                      style: AppText.headline,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A beloved family dining destination since 2005',
                      style: AppText.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            (restaurant?.about as String? ?? '')
                .split('\n')
                .first,
            style: AppText.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
