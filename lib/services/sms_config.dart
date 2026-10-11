/// SMS gateway configuration.
///
/// The gateway is a plain HTTP API with Basic auth:
///
/// ```
/// GET https://<host>/api/basic
///   ?mobileno=91XXXXXXXXXX,91XXXXXXXXXX
///   &senderid=<senderid>
///   &countrycode=ALL
///   &msgtext=<message>
/// ```
///
/// **The app does not call this.** Sending an OTP from the client would put
/// the gateway password in the APK, where anyone can read it, and let a
/// stranger send SMS on the company's account. The CRM sends the OTP
/// server-side when the app posts `event_name: login`; these values live here
/// only so the DLT registration is recorded next to the code that reads the
/// resulting message.
class SmsConfig {
  SmsConfig._();

  /// DLT-registered sender ID. Also the suffix the gateway appends to every
  /// message body.
  static const String senderId = 'SYFLSB';

  /// DLT template id registered for the login OTP.
  static const String otpTemplateId = '1777178863021936003';

  /// The registered template, with `{otp}` where the code goes. Any change to
  /// the wording needs re-approval on the DLT portal before it will deliver.
  static const String otpTemplate =
      'Use OTP {otp} to log in to your Salary Brother account. This code will '
      'expire in 5 minutes. Keep it safe. $senderId';

  /// How long the OTP stays valid, per the template's own wording.
  static const Duration otpValidity = Duration(minutes: 5);

  /// Renders the template for a code, for previews and tests.
  static String otpMessage(String otp) =>
      otpTemplate.replaceFirst('{otp}', otp);
}
