import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/menu_item.dart';
import '../app_badge.dart';
import '../app_network_image.dart';
import '../veg_badge.dart';

/// Horizontal dish tile used on the main Menu screen list.
class MenuTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unavailable = !item.isAvailable;

    return Material(
      color: isDark ? const Color(0xFF1B231E) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    AppNetworkImage(
                      url: item.imageUrl,
                      width: 92,
                      height: 92,
                    ),
                    if (unavailable)
                      Container(
                        width: 92,
                        height: 92,
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: VegBadge(isVeg: item.isVeg),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppText.title.copyWith(fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: AppText.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(formatINR(item.price), style: AppText.price),
                        const SizedBox(width: 10),
                        if (item.isBestseller) const AppBadge.bestseller(),
                        const SizedBox(width: 6),
                        if (item.isSpicy) const AppBadge.spicy(),
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
