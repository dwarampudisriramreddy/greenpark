import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-based skeleton for loading states.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: Color.lerp(base, Colors.white, 0.35)!,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A list of skeleton cards for menu / offers / posts loading states.
class SkeletonCardList extends StatelessWidget {
  final int count;
  final double height;

  const SkeletonCardList({super.key, this.count = 4, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => SkeletonBox(height: height),
    );
  }
}
