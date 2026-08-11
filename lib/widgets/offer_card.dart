import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../data/models/offer.dart';
import 'app_network_image.dart';

/// Banner card for a promotional offer.
class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback? onTap;
  final bool compact;

  const OfferCard({super.key, required this.offer, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: compact ? 280 : 300,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B231E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppNetworkImage(
                    url: offer.bannerUrl,
                    height: compact ? 132 : 140,
                    width: double.infinity,
                    borderRadius: 0,
                  ),
                  if (offer.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (compact)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: AppText.headline.copyWith(fontSize: 16.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            offer.description ?? '',
                            style: AppText.bodySmallFor(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: AppColors.brandGreen),
                            const SizedBox(width: 5),
                            Text(
                              _validityText(offer),
                              style: AppText.bodySmallFor(context).copyWith(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.title, style: AppText.headline.copyWith(fontSize: 16.5)),
                      const SizedBox(height: 6),
                      Text(
                        offer.description ?? '',
                        style: AppText.bodySmallFor(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 14, color: AppColors.brandGreen),
                          const SizedBox(width: 5),
                          Text(
                            _validityText(offer),
                            style: AppText.bodySmallFor(context).copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _validityText(Offer offer) {
    if (offer.validFrom == null && offer.validUntil == null) return 'Ongoing offer';
    if (offer.validUntil == null) return 'Valid from ${formatDate(offer.validFrom!)}';
    if (offer.validFrom == null) return 'Valid till ${formatDate(offer.validUntil!)}';
    if (offer.validFrom!.year == offer.validUntil!.year) {
      return '${formatDate(offer.validFrom!)} - ${formatMonthYear(offer.validUntil!)}';
    }
    return '${formatDate(offer.validFrom!)} - ${formatDate(offer.validUntil!)}';
  }
}
