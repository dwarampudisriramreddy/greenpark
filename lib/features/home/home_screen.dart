import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/launchers.dart';
import '../../data/models/feedback_review.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/offer.dart';
import '../../data/models/post.dart';
import '../../data/models/restaurant_info.dart';
import '../../providers/providers.dart';
import '../../widgets/animated_entrance.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/menu/menu_item_detail_sheet.dart';
import '../../widgets/menu/signature_dish_card.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/post_card.dart';
import '../../widgets/review_card.dart';
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
                  style: AppText.bodySmallFor(context).copyWith(fontSize: 11),
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
    final reviews = ref.watch(publishedReviewsProvider);

    final featured = menu.maybeWhen(
      data: (items) => items.where((i) => i.isBestseller).take(8).toList(),
      orElse: () => <MenuItem>[],
    );
    final featuredOffers = offers.maybeWhen(
      data: (list) {
        final f = list.where((o) => o.isFeatured).toList();
        return f.isNotEmpty ? f : list.take(4).toList();
      },
      orElse: () => <Offer>[],
    );
    final latestPosts = posts.maybeWhen(
      data: (list) => list.take(2).toList(),
      orElse: () => <Post>[],
    );
    final publishedReviews = reviews.maybeWhen(
      data: (list) => list,
      orElse: () => <FeedbackReview>[],
    );
    final infoData = info.maybeWhen(data: (r) => r, orElse: () => null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Showcase top ---------------------------------------------------
        info.when(
          loading: () => const SkeletonBox(height: 420, borderRadius: 0),
          error: (_, _) => const SizedBox.shrink(),
          data: (r) => HeroShowcase(restaurant: r),
        ),

        // Floating glass quick actions overlapping the hero
        if (infoData != null)
          Transform.translate(
            offset: const Offset(0, -30),
            child: AnimatedEntrance(
              delay: const Duration(milliseconds: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GlassActions(restaurant: infoData),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // ---- Must-try signature showcase -----------------------------------
        AnimatedEntrance(
          delay: const Duration(milliseconds: 350),
          child: _section(
            context,
            title: 'Must-try',
            subtitle: 'Our signature dishes',
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            ),
            child: _signatureRow(context, featured),
          ),
        ),

        // ---- Moments ---------------------------------------------------------
        AnimatedEntrance(
          delay: const Duration(milliseconds: 450),
          child: _section(
            context,
            title: 'Moments',
            subtitle: 'Inside Green Park',
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GalleryScreen()),
            ),
            child: gallery.when(
              loading: () => const SizedBox(
                height: 190,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.take(8).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final g = list.take(8).toList()[i];
                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.line.withValues(alpha: 0.7),
                          ),
                        ),
                        child: AppNetworkImage(
                          url: g.imageUrl,
                          width: 150,
                          height: 190,
                          borderRadius: 0,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // ---- Offers carousel -------------------------------------------------
        AnimatedEntrance(
          delay: const Duration(milliseconds: 550),
          child: _section(
            context,
            title: 'Special offers',
            subtitle: 'Limited-time deals',
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OffersScreen()),
            ),
            child: offers.when(
              loading: () => const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (list) {
                if (list.isEmpty) return const SizedBox.shrink();
                return _OffersCarousel(offers: featuredOffers);
              },
            ),
          ),
        ),

        // ---- Guest reviews ---------------------------------------------------
        if (publishedReviews.isNotEmpty)
          AnimatedEntrance(
            delay: const Duration(milliseconds: 650),
            child: _section(
              context,
              title: 'Guest love',
              subtitle: 'What people are saying',
              child: _reviewsRow(publishedReviews),
            ),
          ),

        // ---- Latest updates --------------------------------------------------
        if (latestPosts.isNotEmpty)
          AnimatedEntrance(
            delay: const Duration(milliseconds: 750),
            child: _section(
              context,
              title: 'Latest updates',
              subtitle: 'Fresh from the kitchen',
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PostsScreen()),
              ),
              child: Column(
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
              ),
            ),
          ),

        const SizedBox(height: 24),
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
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _signatureRow(BuildContext context, List<MenuItem> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => AnimatedEntrance(
          delay: Duration(milliseconds: i * 90),
          child: SignatureDishCard(
            item: featured[i],
            onTap: () => _showDishDetail(context, featured[i]),
          ),
        ),
      ),
    );
  }

  Widget _reviewsRow(List<FeedbackReview> reviews) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: reviews.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
      ),
    );
  }

  void _showDishDetail(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuItemDetailSheet(item: item),
    );
  }
}

/// Full-bleed hero with a slow "Ken Burns" zoom and staggered animated copy.
class HeroShowcase extends StatefulWidget {
  final RestaurantInfo restaurant;
  const HeroShowcase({super.key, required this.restaurant});

  @override
  State<HeroShowcase> createState() => _HeroShowcaseState();
}

class _HeroShowcaseState extends State<HeroShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 22))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return Stack(
      children: [
        SizedBox(
          height: 420,
          width: double.infinity,
          child: ClipRect(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: AppNetworkImage(
                url: r.heroImageUrl,
                fit: BoxFit.cover,
                fallbackLabel: 'Green Park',
              ),
            ),
          ),
        ),
        Container(
          height: 420,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.12),
                Colors.black.withValues(alpha: 0.08),
                Colors.black.withValues(alpha: 0.78),
              ],
              stops: const [0.1, 0.45, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 46,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedEntrance(
                offset: const Offset(0, 0.04),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: AppColors.accentGoldLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.park_rounded,
                      color: AppColors.accentGoldLight,
                      size: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'GREEN PARK',
                  style: AppText.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 240),
                child: Text(
                  r.tagline?.isNotEmpty == true
                      ? r.tagline!
                      : 'The Taste of Andhra, in the Heart of Rajahmundry',
                  style: AppText.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 360),
                child: Row(
                  children: [
                    _heroChip(Icons.location_on_rounded, 'Rajanagaram, Rajahmundry'),
                    const SizedBox(width: 8),
                    _heroChip(Icons.star_rounded, 'Family Dining'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentGoldLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating glass quick actions that overlap the hero.
class _GlassActions extends StatelessWidget {
  final RestaurantInfo restaurant;
  const _GlassActions({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B231E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.1),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _glassAction(
            icon: Icons.call_rounded,
            label: 'Call',
            color: AppColors.brandGreen,
            onTap: () => launchCall(restaurant.phone ?? ''),
          ),
          _verticalDivider(isDark),
          _glassAction(
            icon: Icons.chat_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => launchWhatsApp(
              restaurant.whatsapp ?? '',
              message: 'Hello Green Park! I have a question.',
            ),
          ),
          _verticalDivider(isDark),
          _glassAction(
            icon: Icons.navigation_rounded,
            label: 'Directions',
            color: const Color(0xFF4285F4),
            onTap: () => launchDirections(restaurant.mapsUrl),
          ),
        ],
      ),
    );
  }

  Widget _glassAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppText.label.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 44,
      color: isDark ? Colors.white12 : AppColors.line,
    );
  }
}

/// Auto-advancing offer carousel with animated dots.
class _OffersCarousel extends StatefulWidget {
  final List<Offer> offers;
  const _OffersCarousel({required this.offers});

  @override
  State<_OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<_OffersCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if (widget.offers.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.offers.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.offers.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final showGap = i < widget.offers.length - 1;
              return Padding(
                key: ValueKey('offer-$i'),
                padding: EdgeInsets.only(
                  left: 20,
                  right: showGap ? 14 : 20,
                ),
                child: OfferCard(
                  offer: widget.offers[i],
                  compact: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OffersScreen()),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        if (widget.offers.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.offers.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.brandGreen : AppColors.brandMint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
