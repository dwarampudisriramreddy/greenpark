import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/menu_item.dart';
import '../app_badge.dart';
import '../app_network_image.dart';
import '../veg_badge.dart';

/// Compact dish card used in horizontal "featured" strips.
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 190,
        child: Container(
          clipBehavior: Clip.antiAlias,
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
              Stack(
                children: [
                  AppNetworkImage(
                    url: item.imageUrl,
                    height: 118,
                    width: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _VegPill(isVeg: item.isVeg),
                  ),
                  if (item.isBestseller)
                    const Positioned(top: 8, right: 8, child: AppBadge.bestseller()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppText.title.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(formatINR(item.price), style: AppText.price.copyWith(fontSize: 16)),
                        const Spacer(),
                        if (item.isSpicy)
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: AppColors.accentRed,
                          ),
                        const SizedBox(width: 2),
                        if (item.isAvailable == false)
                          const AppBadge.unavailable(),
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
}

class _VegPill extends StatelessWidget {
  final bool isVeg;
  const _VegPill({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
      ),
      child: VegBadge(isVeg: isVeg, size: 14),
    );
  }
}
