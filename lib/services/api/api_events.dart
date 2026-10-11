/// The `event_name` discriminator.
///
/// The CRM has one write endpoint, `saveCustomerProfile`, and `event_name` in
/// the body decides what it does. The same values double as the server's
/// journey state: the response's `Data.next_step` names the event the customer
/// must complete next, which is how the app knows where to send them.
///
/// These strings are the CRM's wire format — do not rename them.
class ApiEvents {
  ApiEvents._();

  static const String login = 'login';
  static const String otpVerify = 'otp_verify';
  static const String resendOtp = 'resend_otp';

  static const String pancard = 'pancard_verification';
  static const String personalDetails = 'personal_details';
  static const String residenceDetails = 'residence_details';
  static const String incomeDetails = 'income_details';
  static const String employmentDetails = 'employment_details';
  static const String bankingDetails = 'banking_details';

  static const String selfieUpload = 'selfie_upload';
  static const String pancardUpload = 'pan_upload';
  static const String aadhaarUpload = 'aadhaar_upload';
  static const String residenceProof = 'residence_proof_upload';
  static const String bankStatementUpload = 'bank_statement_upload';
  static const String paySlipUpload = 'pay_slip_upload';

  static const String registerNow = 'register_now';
  static const String generateLoanQuote = 'generate_loan_quote';
  static const String loanQuotationDecision = 'loan_quotation_decision';
  static const String completed = 'completed';

  /// How far along the journey each event sits. Used to decide whether a
  /// screen may be shown yet, and to compare two steps.
  ///
  /// Several events share a position because they are alternative uploads at
  /// the same stage.
  static const Map<String, int> _order = {
    login: 0,
    otpVerify: 1,
    resendOtp: 2,
    pancard: 3,
    personalDetails: 4,
    residenceDetails: 5,
    incomeDetails: 6,
    selfieUpload: 7,
    registerNow: 8,
    generateLoanQuote: 9,
    loanQuotationDecision: 9,
    employmentDetails: 10,
    bankStatementUpload: 11,
    aadhaarUpload: 11,
    residenceProof: 11,
    pancardUpload: 11,
    paySlipUpload: 11,
    bankingDetails: 12,
    completed: 13,
  };

  /// Position of [event] in the journey, or 0 for anything unrecognised.
  static int positionOf(String? event) => _order[event] ?? 0;

  /// True once the customer has finished the whole application.
  static bool isComplete(String? event) => event == completed;
}
