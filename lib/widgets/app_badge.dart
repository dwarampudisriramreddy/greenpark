import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Small pill badge used for "Bestseller", "Spicy", "Veg" etc.
class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.accentGoldLight,
    this.foreground = const Color(0xFF7A5D10),
  });

  const AppBadge.bestseller({super.key})
      : label = 'Bestseller',
        icon = Icons.auto_awesome,
        background = AppColors.accentGoldLight,
        foreground = const Color(0xFF7A5D10);

  const AppBadge.spicy({super.key})
      : label = 'Spicy',
        icon = Icons.local_fire_department,
        background = AppColors.accentRedLight,
        foreground = AppColors.accentRed;

  const AppBadge.newArrival({super.key})
      : label = 'New',
        icon = Icons.fiber_new_rounded,
        background = AppColors.brandMint,
        foreground = AppColors.brandGreen;

  const AppBadge.unavailable({super.key})
      : label = 'Sold out',
        icon = Icons.remove_circle_outline,
        background = const Color(0xFFEFEFEA),
        foreground = AppColors.inkSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
