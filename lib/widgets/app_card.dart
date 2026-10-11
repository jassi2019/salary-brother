import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';

/// White card with the hairline border used for most sections.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.color = AppColors.white,
    this.border = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border
            ? Border.all(color: AppColors.borderSoft)
            : null,
      ),
      child: child,
    );
  }
}

/// The plum hero card (limit card, welcome hero) with its lattice watermark.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = AppSizes.radiusHero,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: AppColors.primary,
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -80,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: _LatticePainter(),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// The three nested hexagons watermarked on every plum surface.
class _LatticePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.13);

    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    for (final factor in [1.0, 0.72, 0.44]) {
      canvas.drawPath(_hexagon(center, outer * factor), paint);
    }
  }

  Path _hexagon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * 0.866 * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
