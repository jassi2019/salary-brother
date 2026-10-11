import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';

/// The app's toast.
///
/// `Get.snackbar` defaults to black 300-weight text on a 20%-opacity grey
/// panel, which on a white screen in daylight is close to invisible — an
/// error shown that way reads as "nothing happened". GetSnackBar also ignores
/// Material's `snackBarTheme`, so the styling has to be passed every time.
/// This wraps it once so no caller has to remember.
class AppToast {
  AppToast._();

  static void error(String message) => _show(message, AppColors.error);

  static void info(String message) => _show(message, AppColors.ink);

  static void success(String message) => _show(message, AppColors.success);

  static void _show(String message, Color background) {
    if (message.trim().isEmpty) return;

    // Replace rather than stack, so a burst of failures does not bury the
    // screen in panels.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontBody,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: background,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSizes.m),
      borderRadius: AppSizes.radiusOtpBox,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}
