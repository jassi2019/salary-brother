/// Every backend path in one place. Swap [baseUrl] per environment.
class ApiEndpoints {
  ApiEndpoints._();

  /// TODO: point this at the real Salary Brother backend.
  static const String baseUrl = 'https://api.salarybrother.com/v1';

  // auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';

  // profile + application
  static const String profile = '/user/profile';
  static const String personalDetails = '/user/personal-details';
  static const String employmentDetails = '/user/employment-details';
  static const String bankDetails = '/user/bank-details';

  // kyc
  static const String panVerify = '/kyc/pan';
  static const String aadhaarInitiate = '/kyc/aadhaar/initiate';
  static const String aadhaarVerify = '/kyc/aadhaar/verify';

  // loan
  static const String loanLimit = '/loan/limit';
  static const String loanQuote = '/loan/quote';
  static const String loanApply = '/loan/apply';
  static const String loanStatus = '/loan/status';
  static const String loanHistory = '/loan/history';
  static const String repaymentLink = '/loan/repayment-link';
}
