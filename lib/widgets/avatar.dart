import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';

/// The customer's selfie, falling back to their initials.
///
/// The photo is whatever `getDashboardData` returns as `profile_pic`, which
/// the CRM fills in once the selfie upload has been accepted.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.user,
    this.size = 56,
    this.fontSize = 18,
  });

  final UserModel? user;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final radius = size <= AppSizes.touchTarget
        ? AppSizes.radiusOtpBox
        : AppSizes.radiusCardSmall;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: AppColors.tint,
        child: user?.hasPhoto ?? false
            ? Image.network(
                user!.profilePicUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                // A broken or slow photo must not leave an empty square.
                errorBuilder: (_, __, ___) => _initials(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _initials(),
              )
            : _initials(),
      ),
    );
  }

  Widget _initials() => Text(
        user?.initials ?? 'SB',
        style: TextStyle(
          fontFamily: AppTextStyles.fontHeading,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      );
}
