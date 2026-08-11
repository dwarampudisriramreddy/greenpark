import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'app_network_image.dart';

/// The Green Park logo, always rendered as a circle on a solid brand
/// background so transparent corners can never show through.
class AppLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const AppLogo({super.key, this.logoUrl, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.paper,
      ),
      child: hasLogo
          ? AppNetworkImage(
              url: logoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              borderRadius: size / 2,
              backgroundColor: AppColors.paper,
            )
          : Image.asset(
              'assets/images/icon.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
    );
  }
}
