/// Company and brand details, and every outward-facing link.
///
/// Ported from SalaryUncle: the operating company is the same, only the brand
/// and its domain change. Anything still marked TODO needs the Salary Brother
/// equivalent before launch.
class BrandConfig {
  BrandConfig._();

  // --- brand --------------------------------------------------------------
  static const String brandName = 'Salary Brother';
  static const String website = 'https://salarybrother.com';

  /// TODO: confirm the Play Store package and App Store id for this brand.
  static const String androidPackage = 'com.salarybrother.salary_brother';
  static const String iosAppId = '';

  // --- operating company --------------------------------------------------
  // TODO: confirm the registered entity behind this brand. SalaryUncle's is
  // Julania Finance Private Limited, but Salary Brother's corporate office is
  // a different address, so the entity may differ too.
  static const String companyName = '';

  /// The corporate office, as published on the website.
  static const String companyAddress =
      'C2/13, Oahfeo De Vibe, 2nd Floor, Ashok Vihar Phase 2, North Delhi';

  // --- contact ------------------------------------------------------------
  // From the Salary Brother website's Get in Touch section.
  static const String phone = '+917428280884';
  static const String whatsapp = '+917303095541';
  static const String email = 'customer.care@salarybrother.com';

  /// Shown next to the support number.
  static const String supportHours = 'Monday – Saturday, 9 AM to 7 PM';

  // --- legal --------------------------------------------------------------
  // RBI digital-lending rules require these to be reachable from the app.
  // TODO: both paths are placeholders today — the pages do not exist yet.
  // The app must not ship until they serve the real policies.
  static const String privacyPolicyUrl = '$website/privacy-policy';
  static const String termsUrl = '$website/terms-and-conditions';

  /// TODO: the registered NBFC whose name must appear on the welcome screen.
  static const String nbfcPartnerName = '[NBFC Partner Name]';

  // --- social -------------------------------------------------------------
  // TODO: no Salary Brother social profiles are linked from the site yet.
  static const String instagram = '';
  static const String facebook = '';
  static const String twitter = '';

  static const String mapsUrl =
      'https://www.google.com/maps/search/?api=1&query='
      'Oahfeo%20De%20Vibe%2C%20Ashok%20Vihar%20Phase%202%2C%20Delhi';

  /// Screens hide a contact affordance rather than open an empty link.
  static bool get hasPhone => phone.isNotEmpty;
  static bool get hasWhatsapp => whatsapp.isNotEmpty;
  static bool get hasEmail => email.isNotEmpty;
  static bool get hasAnyContact => hasPhone || hasWhatsapp || hasEmail;

  static bool get hasSocialLinks =>
      instagram.isNotEmpty || facebook.isNotEmpty || twitter.isNotEmpty;

  /// True while any launch-blocking detail is still a placeholder. Useful as a
  /// release check: this must be false before the app ships.
  static bool get hasPlaceholders =>
      !hasAnyContact ||
      companyName.isEmpty ||
      nbfcPartnerName.startsWith('[');
}
