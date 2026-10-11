/// Asset paths. Add the file to assets/ and register the path here.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  /// Full-colour mark: white monogram on the plum tile.
  static const String logo = '$_images/logo.png';

  /// The monogram alone, white with a transparent ground, for drawing on
  /// plum or inside a tile of our own.
  static const String logoMark = '$_images/logo_mark_trim.png';
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';

  static const String iconHome = '$_icons/home.png';
  static const String iconProfile = '$_icons/profile.png';
}
