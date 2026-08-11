import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/menu_item.dart';
import '../app_badge.dart';
import '../app_network_image.dart';
import '../veg_badge.dart';

/// Large, image-forward dish card for the home "Must-try" showcase.
class SignatureDishCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const SignatureDishCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 240,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B231E) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(url: item.imageUrl, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.74),
                    ],
                    stops: const [0.25, 0.55, 1],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: VegBadge(isVeg: item.isVeg, size: 15),
                ),
              ),
              if (item.isBestseller)
                const Positioned(top: 10, right: 10, child: AppBadge.bestseller()),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppText.displaySmall.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          formatINR(item.price),
                          style: AppText.headline.copyWith(
                            color: AppColors.accentGoldLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (item.isSpicy)
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        if (item.isAvailable == false) ...[
                          const SizedBox(width: 6),
                          const Text(
                            'SOLD OUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
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
