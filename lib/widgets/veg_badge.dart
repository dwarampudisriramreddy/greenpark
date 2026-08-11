import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Standard Indian veg (green square with green dot) / non-veg
/// (red-brown square with triangle) marker.
class VegBadge extends StatelessWidget {
  final bool isVeg;
  final double size;

  const VegBadge({super.key, required this.isVeg, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.vegGreen : AppColors.nonVegRed;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.6),
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: isVeg
          ? Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : CustomPaint(
              painter: _TrianglePainter(color),
            ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.12)
      ..lineTo(size.width * 0.92, size.height * 0.88)
      ..lineTo(size.width * 0.08, size.height * 0.88)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
