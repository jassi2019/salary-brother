import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// The hexagon "SB" mark plus the stacked SALARY / BROTHER wordmark.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexMarkPainter(),
        child: Center(
          child: Text(
            'SB',
            style: TextStyle(
              fontFamily: AppTextStyles.fontHeading,
              fontSize: size * 0.31,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SALARY',
              style: TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 1.1,
                color: AppColors.primary,
              ),
            ),
            Text(
              'BROTHER',
              style: TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                height: 1.1,
                color: AppColors.brandMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HexMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * 0.866 * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = AppColors.primary..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
