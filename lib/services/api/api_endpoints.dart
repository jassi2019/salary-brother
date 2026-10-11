/// Endpoint paths on the Salary Brother CRM.
///
/// These mirror the SalaryUncle CRM one-for-one — only the host differs.
/// Only the paths the app actually calls are listed; the CRM's constant file
/// carries a dozen more that nothing uses.
///
/// Write no leading slash: [ApiConfig.url] adds the separator, so a leading
/// slash here produces a doubled `//` in the URL.
class ApiEndpoints {
  ApiEndpoints._();

  /// Customer-profile writes: login, OTP, resend, PAN, personal, residence and
  /// income details, `register_now`, and the selfie upload. `event_name` in
  /// the body decides which. See [ApiEvents].
  static const String saveCustomerProfile = 'saveCustomerProfile';

  /// Lead writes: employment and banking details, the loan quote and its
  /// decision, and the five non-selfie document uploads. Same `event_name`
  /// discriminator.
  ///
  /// The upload split is easy to get wrong: `selfie_upload` goes to
  /// [saveCustomerProfile], every other upload event comes here.
  static const String saveLeadDetails = 'saveleadDetails';

  // --- reads --------------------------------------------------------------
  static const String getLeadList = 'getLeadList';
  static const String getDashboardData = 'getDashboardData';
  static const String getLeadDetail = 'getLeadDetail';
  static const String mandatoryDocuments = 'mandatoryDocuments';

  // --- misc ---------------------------------------------------------------
  static const String feedback = 'feedback';
  static const String checkAppVersion = 'checkInstantAppVersion';

  // --- payments -----------------------------------------------------------
  static const String generateRazorpayOrderId = 'generateRazorpayorderId';
  static const String verifyRazorpayPaymentStatus =
      'verifyRazorPayCheckPaymentStatus';

  /// Aadhaar OKYC sits on its own module: these two paths skip the platform
  /// prefix and answer with a different envelope (`statusCode` / `data`)
  /// than everything else. Call them with [ApiConfig.unprefixedUrl].
  static const String okycSendOtp = 'getOkycOtp';
  static const String okycFetchData = 'fetchOkycData';
}
