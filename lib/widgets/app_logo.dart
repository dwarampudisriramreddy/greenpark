import 'package:flutter/material.dart';

import 'app_network_image.dart';

/// The Green Park logo. Uses the CMS logo when available.
class AppLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const AppLogo({super.key, this.logoUrl, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    if (hasLogo) {
      return AppNetworkImage(
        url: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        borderRadius: size / 2,
        backgroundColor: Colors.transparent,
      );
    }
    // Branded fallback: the bundled Green Park logo asset.
    return ClipOval(
      child: Image.asset(
        'assets/images/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
