import 'package:flutter/material.dart';

/// Design tokens from the "Salary Brother App UI" canvas.
/// Never hard-code a Color in a widget — add it here first.
class AppColors {
  AppColors._();

  // brand
  static const Color primary = Color(0xFF840753); // plum
  static const Color primaryDark = Color(0xFF5A0438);
  static const Color primaryDeep = Color(0xFF4A0430);
  static const Color tint = Color(0xFFE8CDD6);
  static const Color tintSoft = Color(0xFFF6E7EE);

  // surfaces
  static const Color surface = Color(0xFFFBF5F8);
  static const Color white = Color(0xFFFFFFFF);

  // text
  static const Color ink = Color(0xFF1F1219);
  static const Color inkSoft = Color(0xFF4A3842);
  static const Color muted = Color(0xFF6B5662);
  static const Color mutedLight = Color(0xFF7A6470);
  static const Color onPrimaryMuted = Color(0xFFF3E3EA);
  static const Color brandMuted = Color(0xFF8E5F79);

  // status
  static const Color success = Color(0xFF0B7A5C);
  static const Color successSurface = Color(0xFFE3F4EE);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFC2185B);

  // lines
  static const Color border = Color(0xFFE9D6DF);
  static const Color borderSoft = Color(0xFFF0E2E8);
  static const Color divider = Color(0xFFF1E4EA);
  static const Color disabled = Color(0xFFE1CCD6);

  /// Shadow under primary buttons and floating cards.
  static const Color primaryShadow = Color(0x40840753);
}
