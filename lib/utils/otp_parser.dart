import '../controllers/auth_controller.dart';
import '../services/sms_config.dart';

/// Pulls the login code out of an incoming SMS.
///
/// The registered template is fixed, so matching it is safer than grabbing the
/// first digits in the message — a body that mentions "5 minutes" or the
/// template id would otherwise yield the wrong code.
class OtpParser {
  OtpParser._();

  /// Matches the code where the registered template puts it: after "OTP " and
  /// before " to log in".
  static final RegExp _templated = RegExp(
    r'\bOTP\s+(\d{' '${AuthController.otpLength}' r'})\b(?=\s+to\s+log\s+in)',
    caseSensitive: false,
  );

  /// Looser fallback, for a gateway that reworded the message: the code must
  /// still follow the word OTP.
  static final RegExp _afterKeyword = RegExp(
    r'\b(?:OTP|code|password)\D{0,12}(\d{' '${AuthController.otpLength}' r'})\b',
    caseSensitive: false,
  );

  /// The code, or null when [body] is not one of our OTP messages.
  ///
  /// Returns null if the sender ID is absent, so another app's OTP is never
  /// typed into this one.
  static String? extract(String? body) {
    final text = (body ?? '').trim();
    if (text.isEmpty) return null;
    if (!text.toUpperCase().contains(SmsConfig.senderId)) return null;

    for (final pattern in [_templated, _afterKeyword]) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    return null;
  }
}
