import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows a locally-picked image preview, falling back to [fallback]
/// (usually a network image) when no bytes are available.
class PickedImagePreview extends StatelessWidget {
  final Uint8List? bytes;
  final Widget? fallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const PickedImagePreview({
    super.key,
    this.bytes,
    this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(bytes!, width: width, height: height, fit: fit),
      );
    }
    return fallback ?? const SizedBox.shrink();
  }
}
