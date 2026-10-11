/// Spacing and radius scale from the design canvas.
/// 8 px grid; touch targets never below 44 px.
class AppSizes {
  AppSizes._();

  // spacing
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Horizontal screen padding used on every screen.
  static const double screenPadding = 20;

  // radius
  static const double radiusButton = 18;
  static const double radiusField = 16;
  static const double radiusOtpBox = 14;
  static const double radiusCard = 20;
  static const double radiusCardSmall = 18;
  static const double radiusHero = 32;
  static const double radiusPill = 999;

  // heights
  static const double buttonHeight = 56;
  static const double fieldHeight = 56;
  static const double otpBoxHeight = 58;
  static const double touchTarget = 44;
  static const double iconBadge = 34;
}
