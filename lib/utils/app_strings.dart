/// User-facing copy. Keeping it here makes localisation a drop-in later.
class AppStrings {
  AppStrings._();

  static const String appName = 'Salary Brother';
  static const String tagline = 'Salary advance, without the wait';

  // auth
  static const String login = 'Login';
  static const String enterMobile = 'Enter your mobile number';
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify OTP';
  static const String otpSentTo = 'OTP sent to';
  static const String resendOtp = 'Resend OTP';

  // generic
  static const String contin = 'Continue';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';

  // errors
  static const String noInternet = 'No internet connection';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String invalidMobile = 'Enter a valid 10-digit mobile number';
  static const String invalidOtp = 'Enter the 6-digit OTP';
}
