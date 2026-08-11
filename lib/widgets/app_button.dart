import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Rounded primary action button used across the app (Call, Directions, etc).
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.filled = true,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.brandGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColors.brandGreen,
            side: const BorderSide(color: AppColors.brandGreen, width: 1.4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expanded ? MainAxisAlignment.center : MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700))),
      ],
    );
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: filled
          ? FilledButton(onPressed: onPressed, style: style, child: child)
          : OutlinedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}
