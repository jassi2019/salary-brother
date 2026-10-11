/// Razorpay configuration.
///
/// The key is read from the build environment, never committed. Pass it at
/// build time:
///
/// ```
/// flutter build apk --dart-define=RAZORPAY_KEY=rzp_live_xxxxxxxx
/// ```
///
/// SalaryUncle hardcodes its live key in the client, where anyone who unzips
/// the APK can read it. That is not carried over here.
class PaymentConfig {
  PaymentConfig._();

  static const String razorpayKey = String.fromEnvironment('RAZORPAY_KEY');

  /// False when the app was built without a key, so payment screens can show
  /// an error instead of opening a checkout that cannot work.
  static bool get isConfigured => razorpayKey.isNotEmpty;
}
