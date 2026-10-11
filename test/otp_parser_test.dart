import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/services/sms_config.dart';
import 'package:salary_brother/utils/otp_parser.dart';

void main() {
  group('the registered template', () {
    test('renders the sample content exactly', () {
      // This is the body approved on the DLT portal. If it stops matching,
      // the template was edited without re-approval and delivery will fail.
      expect(
        SmsConfig.otpMessage('1234'),
        'Use OTP 1234 to log in to your Salary Brother account. This code '
        'will expire in 5 minutes. Keep it safe. SYFNSB',
      );
    });

    test('carries the sender ID and a 5-minute validity', () {
      expect(SmsConfig.senderId, 'SYFNSB');
      expect(SmsConfig.otpTemplateId, '1777178866858679772');
      expect(SmsConfig.peId, '1701178833315739006');
      expect(SmsConfig.otpValidity, const Duration(minutes: 5));
      expect(SmsConfig.otpTemplate, contains(SmsConfig.senderId));
    });
  });

  group('OtpParser.extract', () {
    test('reads the code out of the real message', () {
      expect(OtpParser.extract(SmsConfig.otpMessage('1234')), '1234');
      expect(OtpParser.extract(SmsConfig.otpMessage('8290')), '8290');
    });

    test('survives the prefixes carriers add', () {
      const body =
          'AD-SYFNSB: Use OTP 4821 to log in to your Salary Brother account. '
          'This code will expire in 5 minutes. Keep it safe. SYFNSB';

      expect(OtpParser.extract(body), '4821');
    });

    test('does not mistake the "5 minutes" for the code', () {
      // A naive "first digits" parser returns 1234 here only by luck; make
      // sure the code comes from the template's own slot.
      final code = OtpParser.extract(SmsConfig.otpMessage('9999'));
      expect(code, '9999');
      expect(code, isNot('5'));
    });

    test('ignores another sender\'s OTP', () {
      const other =
          'Use OTP 5566 to log in to your SomeOtherApp account. ABCDEF';

      expect(OtpParser.extract(other), isNull);
    });

    test('ignores a message from us that carries no code', () {
      const promo = 'Your Salary Brother loan is approved. SYFNSB';

      expect(OtpParser.extract(promo), isNull);
    });

    test('handles a reworded body that still names the code', () {
      const reworded = 'SYFNSB Your code is 3344. Do not share it.';

      expect(OtpParser.extract(reworded), '3344');
    });

    test('rejects empty and null input', () {
      expect(OtpParser.extract(null), isNull);
      expect(OtpParser.extract(''), isNull);
      expect(OtpParser.extract('   '), isNull);
    });

    test('does not return a code of the wrong length', () {
      const sixDigits = 'SYFNSB Use OTP 123456 to log in to your account.';

      // The CRM issues 4-digit codes; a 6-digit one is not ours.
      expect(OtpParser.extract(sixDigits), isNull);
    });
  });

  group('the gateway signs with JULANA today', () {
    test('a real live message parses', () {
      // Verbatim from a device, 2026-10-11. The gateway is signing with the
      // operating company's name instead of the registered sender ID; until
      // that is fixed at the gateway, these must still auto-fill.
      const live = 'Use OTP 6055 to log in to your Salary Brother account. '
          'This code will expire in 5 minutes. Keep it safe. JULANA';

      expect(OtpParser.extract(live), '6055');
    });

    test('both sender IDs are accepted', () {
      expect(SmsConfig.acceptedSenderIds, contains('SYFNSB'));
      expect(SmsConfig.acceptedSenderIds, contains('JULANA'));
    });

    test('a third party is still rejected', () {
      // Widening the sender list must not make the parser accept anyone.
      const other =
          'Use OTP 5566 to log in to your SomeOtherApp account. ABCDEF';

      expect(OtpParser.extract(other), isNull);
    });
  });
}
