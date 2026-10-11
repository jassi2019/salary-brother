import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';

/// The 44x44 rounded-square icon button used in every screen header.
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background = AppColors.white,
    this.showBorder = true,
    this.badge = false,
  });

  final IconData icon;

  /// Doubles as the accessibility label, so icon-only buttons stay readable.
  final String tooltip;
  final VoidCallback? onPressed;
  final Color background;
  final bool showBorder;

  /// Shows the unread dot used on the notifications button.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: AppSizes.touchTarget,
          height: AppSizes.touchTarget,
          child: Material(
            color: background,
            // One or the other: Material asserts if both are given. The shape
            // carries the radius, with a border only when asked for.
            shape: RoundedRectangleBorder(
              side: showBorder
                  ? const BorderSide(color: AppColors.borderSoft)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(AppSizes.radiusOtpBox),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(AppSizes.radiusOtpBox),
              child: Stack(
                children: [
                  Center(child: Icon(icon, size: 22, color: AppColors.ink)),
                  if (badge)
                    Positioned(
                      top: 9,
                      right: 10,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
