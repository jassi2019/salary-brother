import 'package:flutter/material.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// The Salary Brother mark — the interlocked SB monogram — with an optional
/// stacked SALARY / BROTHER wordmark beside it.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 40,
    this.showWordmark = true,
    this.onPlum = false,
  });

  final double size;
  final bool showWordmark;

  /// True when the logo sits on a plum surface: the mark is drawn white and
  /// loses its tile, rather than putting plum on plum.
  final bool onPlum;

  @override
  Widget build(BuildContext context) {
    final mark = onPlum
        ? Image.asset(
            AppAssets.logoMark,
            width: size,
            height: size,
            fit: BoxFit.contain,
          )
        : Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.17),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(size * 0.26),
            ),
            child: Image.asset(AppAssets.logoMark, fit: BoxFit.contain),
          );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        _Wordmark(onPlum: onPlum),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onPlum});

  final bool onPlum;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            color: onPlum ? Colors.white : AppColors.primary,
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
            color: onPlum ? AppColors.tint : AppColors.brandMuted,
          ),
        ),
      ],
    );
  }
}
