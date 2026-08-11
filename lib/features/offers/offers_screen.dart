import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/offer.dart';
import '../../providers/providers.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/offer_card.dart';
import '../../widgets/skeleton.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: offers.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 4,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonBox(height: 250),
            ),
          ),
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: ErrorView(
                  message: 'Could not load offers. Pull to refresh.',
                  onRetry: () async => refreshAllContent(ref),
                ),
              ),
            ],
          ),
          data: (list) {
            final sorted = [...list]..sort((a, b) {
                if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
                return b.createdAt.compareTo(a.createdAt);
              });
            if (sorted.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 52, color: AppColors.brandGreen),
                          SizedBox(height: 12),
                          Text('No offers right now'),
                          SizedBox(height: 4),
                          Text('Check back soon for new deals!'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _OffersIntro(),
                const SizedBox(height: 18),
                for (final offer in sorted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OfferCard(
                        offer: offer,
                        onTap: () => _showOfferDetail(context, offer),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showOfferDetail(BuildContext context, Offer offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OfferDetailSheet(offer: offer),
    );
  }
}

class _OffersIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deals made for families', style: AppText.headline.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Offers change regularly. Ask our team for details when you visit.',
                  style: AppText.bodySmallFor(context).copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferDetailSheet extends StatelessWidget {
  final Offer offer;
  const _OfferDetailSheet({required this.offer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A16) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(999))),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AppNetworkImage(url: offer.bannerUrl, height: 220, width: double.infinity),
                      if (offer.isFeatured)
                        const Positioned(
                          top: 14,
                          left: 14,
                          child: _FeaturePill(),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.title, style: AppText.displaySmall),
                        if (offer.description != null && offer.description!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(offer.description!, style: AppText.body),
                        ],
                        const SizedBox(height: 16),
                        _ValidityRow(offer: offer),
                        if (offer.terms != null && offer.terms!.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text('Terms & Conditions', style: AppText.headline.copyWith(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(offer.terms!, style: AppText.bodySmallFor(context).copyWith(height: 1.8)),
                        ],
                        const SizedBox(height: 22),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.greenSurface(context),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Show this offer at the counter',
                              style: AppText.title.copyWith(fontSize: 12.5, color: AppColors.brandGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'FEATURED OFFER',
            style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ValidityRow extends StatelessWidget {
  final Offer offer;
  const _ValidityRow({required this.offer});

  @override
  Widget build(BuildContext context) {
    final start = offer.validFrom;
    final end = offer.validUntil;
    String text;
    if (start == null && end == null) {
      text = 'Ongoing offer';
    } else if (end == null) {
      text = 'Valid from ${formatDate(start!)}';
    } else if (start == null) {
      text = 'Valid till ${formatDate(end)}';
    } else {
      text = '${formatDate(start)} to ${formatDate(end)}';
    }
    return Row(
      children: [
        const Icon(Icons.event_available_rounded, size: 18, color: AppColors.brandGreen),
        const SizedBox(width: 8),
        Text(text, style: AppText.title.copyWith(fontSize: 13.5)),
      ],
    );
  }
}
