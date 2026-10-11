import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

/// Bridges `smart_auth` to Pinput's [SmsRetriever] so the OTP boxes fill
/// themselves from the incoming SMS.
///
/// Uses the **SMS User Consent API** (`useUserConsentApi: true`): Android
/// shows a one-tap consent dialog for the incoming message and hands back the
/// code. It works with any message format, unlike the SMS Retriever API,
/// which needs an 11-character app hash appended to the SMS — and the CRM's
/// DLT-registered template has no room for one.
class SmsRetrieverImpl implements SmsRetriever {
  SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  bool get listenForMultipleSms => false;

  @override
  Future<String?> getSmsCode() async {
    final result = await smartAuth.getSmsCode(useUserConsentApi: true);
    return result.succeed && result.codeFound ? result.code : null;
  }

  @override
  Future<void> dispose() => smartAuth.removeSmsListener();
}
