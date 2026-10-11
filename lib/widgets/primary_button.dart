import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';

/// The plum call-to-action button with its drop shadow, as drawn in the design.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.showIcon = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData trailingIcon;
  final bool showIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.button),
                  if (showIcon) ...[
                    const SizedBox(width: AppSizes.s),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
