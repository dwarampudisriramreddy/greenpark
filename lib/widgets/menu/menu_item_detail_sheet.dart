import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/menu_item.dart';
import '../app_badge.dart';
import '../app_network_image.dart';
import '../veg_badge.dart';

/// Full dish details shown as a bottom sheet (no ordering — display only).
class MenuItemDetailSheet extends StatelessWidget {
  final MenuItem item;

  const MenuItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A16) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AppNetworkImage(
                        url: item.imageUrl,
                        height: 280,
                        width: double.infinity,
                        borderRadius: 0,
                        backgroundColor: AppColors.greenSurface(context),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: VegBadge(isVeg: item.isVeg, size: 18),
                        ),
                      ),
                      if (!item.isAvailable)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'TEMPORARILY SOLD OUT',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(item.name, style: AppText.displaySmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(formatINR(item.price), style: AppText.price.copyWith(fontSize: 22)),
                            const Spacer(),
                            if (item.isBestseller) const AppBadge.bestseller(),
                            const SizedBox(width: 8),
                            if (item.isSpicy) const AppBadge.spicy(),
                          ],
                        ),
                        if (item.description != null && item.description!.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text('About this dish', style: AppText.headline.copyWith(fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(item.description!, style: AppText.body),
                        ],
                        const SizedBox(height: 18),
                        Text('Details', style: AppText.headline.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DetailChip(
                              icon: item.isVeg ? Icons.eco_rounded : Icons.egg_alt_rounded,
                              label: item.isVeg ? 'Pure Vegetarian' : 'Non-Vegetarian',
                            ),
                            _DetailChip(
                              icon: Icons.local_fire_department_rounded,
                              label: item.isSpicy ? 'Spicy' : 'Mild',
                            ),
                            _DetailChip(
                              icon: item.isAvailable
                                  ? Icons.check_circle_rounded
                                  : Icons.remove_circle_outline_rounded,
                              label: item.isAvailable ? 'Available today' : 'Sold out',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Available at Green Park Family Restaurant\nRajanagaram · Rajahmundry',
                            textAlign: TextAlign.center,
                            style: AppText.bodySmallFor(context),
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

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.greenSurface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.green(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.title.copyWith(fontSize: 12, color: AppColors.green(context)),
          ),
        ],
      ),
    );
  }
}
