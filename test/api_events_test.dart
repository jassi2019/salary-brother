import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/services/api/api_events.dart';

void main() {
  group('ApiEvents.positionOf', () {
    test('orders the journey from login to completed', () {
      expect(ApiEvents.positionOf(ApiEvents.login), 0);
      expect(ApiEvents.positionOf(ApiEvents.pancard), 3);
      expect(ApiEvents.positionOf(ApiEvents.bankingDetails), 12);
      expect(ApiEvents.positionOf(ApiEvents.completed), 13);
    });

    test('the sequence is monotonic through the main steps', () {
      const sequence = [
        ApiEvents.login,
        ApiEvents.otpVerify,
        ApiEvents.pancard,
        ApiEvents.personalDetails,
        ApiEvents.residenceDetails,
        ApiEvents.incomeDetails,
        ApiEvents.selfieUpload,
        ApiEvents.registerNow,
        ApiEvents.employmentDetails,
        ApiEvents.bankingDetails,
        ApiEvents.completed,
      ];

      for (var i = 1; i < sequence.length; i++) {
        expect(
          ApiEvents.positionOf(sequence[i]),
          greaterThan(ApiEvents.positionOf(sequence[i - 1])),
          reason: '${sequence[i]} should come after ${sequence[i - 1]}',
        );
      }
    });

    test('the alternative uploads all sit at the same stage', () {
      const uploads = [
        ApiEvents.bankStatementUpload,
        ApiEvents.aadhaarUpload,
        ApiEvents.residenceProof,
        ApiEvents.pancardUpload,
        ApiEvents.paySlipUpload,
      ];

      for (final event in uploads) {
        expect(ApiEvents.positionOf(event), 11);
      }
    });

    test('quote and quotation decision share a stage', () {
      expect(
        ApiEvents.positionOf(ApiEvents.generateLoanQuote),
        ApiEvents.positionOf(ApiEvents.loanQuotationDecision),
      );
    });

    test('an unknown or null step falls back to the start', () {
      expect(ApiEvents.positionOf('something_new'), 0);
      expect(ApiEvents.positionOf(null), 0);
      expect(ApiEvents.positionOf(''), 0);
    });
  });

  group('ApiEvents.isComplete', () {
    test('only "completed" counts as finished', () {
      expect(ApiEvents.isComplete(ApiEvents.completed), isTrue);
      expect(ApiEvents.isComplete(ApiEvents.bankingDetails), isFalse);
      expect(ApiEvents.isComplete(null), isFalse);
    });
  });

  group('wire format', () {
    test('event names match the CRM strings exactly', () {
      // These travel as `event_name`; a rename breaks every call.
      expect(ApiEvents.login, 'login');
      expect(ApiEvents.otpVerify, 'otp_verify');
      expect(ApiEvents.resendOtp, 'resend_otp');
      expect(ApiEvents.pancard, 'pancard_verification');
      expect(ApiEvents.pancardUpload, 'pan_upload');
      expect(ApiEvents.aadhaarUpload, 'aadhaar_upload');
      expect(ApiEvents.residenceProof, 'residence_proof_upload');
      expect(ApiEvents.generateLoanQuote, 'generate_loan_quote');
    });
  });
}
