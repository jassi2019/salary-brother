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
  // Salary Brother is a brand operated through this entity, which is also the
  // RBI-registered NBFC that sanctions and disburses the loans. Taken from the
  // website's footer and terms — note "Finlease", not "Finance".
  static const String companyName = 'Sanyog Finlease Private Limited';

  /// RBI certificate of registration number, shown in the footer disclosure.
  static const String rbiRegistrationNumber = 'B-14.02050';

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
  static const String privacyPolicyUrl = '$website/privacy-policy';
  static const String termsUrl = '$website/terms-and-conditions';
  static const String grievanceUrl = '$website/grievance';

  /// Grievance Redressal Officer, as named in the privacy policy.
  static const String grievanceEmail = 'Grievance@salarybrother.com';

  /// The lender of record. Same entity as [companyName] here: Salary Brother
  /// is a brand of the NBFC rather than a third party's service provider.
  static const String nbfcPartnerName = companyName;

  /// The RBI disclosure for the welcome screen. Every lender in India must
  /// name the registered entity behind the app.
  static const String lenderDisclosure =
      'Loans are offered by $companyName, an RBI-registered NBFC '
      '(Reg. No. $rbiRegistrationNumber). $brandName is its brand.';

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
      rbiRegistrationNumber.isEmpty;
}
