import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Cached network image with a soft shimmer placeholder and a graceful
/// error fallback. Styling is brand-consistent across the app.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;
  final String fallbackLabel;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.backgroundColor,
    this.fallbackLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    if (url == null || url!.isEmpty) {
      return _Fallback(width: width, height: height, color: bg, label: fallbackLabel);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => _ShimmerBox(color: bg),
        errorWidget: (_, _, _) => _Fallback(
          width: width,
          height: height,
          color: bg,
          label: fallbackLabel,
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final Color color;
  const _ShimmerBox({required this.color});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = _controller.value;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.color,
                Color.lerp(widget.color, AppColors.brandMint, 0.35 + t * 0.3)!,
                widget.color,
              ],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  final double? width;
  final double? height;
  final Color color;
  final String label;
  const _Fallback({this.width, this.height, required this.color, this.label = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: 30,
        color: AppColors.green(context),
      ),
    );
  }
}
