/// Route name constants. Use these instead of raw strings everywhere.
///
/// The CRM drives navigation through `event_name`; [JourneyService] maps those
/// events to these routes.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String dashboard = '/dashboard';

  // KYC and profile steps, in the order the CRM asks for them
  static const String kycPan = '/kyc/pan';
  static const String personalDetails = '/personal-details';
  static const String residenceDetails = '/residence-details';
  static const String incomeDetails = '/income-details';
  static const String employmentDetails = '/employment-details';
  static const String bankDetails = '/bank-details';

  /// Shared upload screen. Takes `{'isSelfie': bool}` as arguments.
  static const String documents = '/documents';

  // loan flow
  static const String applyAmount = '/apply/amount';
  static const String review = '/review';
  static const String success = '/success';
  static const String repay = '/repay';

  // misc
  static const String profile = '/profile';
  static const String support = '/support';
  static const String privacyPolicy = '/privacy-policy';
}
