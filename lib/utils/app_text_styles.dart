import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale from the design canvas.
/// Sora for amounts and headings, Manrope for body.
class AppTextStyles {
  AppTextStyles._();

  static const String fontHeading = 'Sora';
  static const String fontBody = 'Manrope';

  // Sora — headings and amounts
  static const TextStyle amountHero = TextStyle(
    fontFamily: fontHeading,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.84,
    height: 1.15,
    color: Colors.white,
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: fontHeading,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.84,
    color: AppColors.ink,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.51,
    height: 1.12,
    color: AppColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
    height: 1.2,
    color: AppColors.ink,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontHeading,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  // Manrope — body
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    height: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    height: 1.5,
    color: AppColors.muted,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.inkSoft,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    color: AppColors.muted,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    color: AppColors.muted,
  );

  static const TextStyle smallBold = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle legal = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    height: 1.5,
    color: AppColors.mutedLight,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle pill = TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.88,
    color: Colors.white,
  );

  static const TextStyle otpDigit = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
}
