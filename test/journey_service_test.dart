import 'package:flutter_test/flutter_test.dart';
import 'package:salary_brother/routes/app_pages.dart';
import 'package:salary_brother/services/api/api_events.dart';
import 'package:salary_brother/services/journey_service.dart';

void main() {
  group('routeFor', () {
    test('maps every event the CRM can send', () {
      // An unmapped event logs the customer out, so a gap here is a
      // user-visible failure, not a cosmetic one.
      const events = [
        ApiEvents.login,
        ApiEvents.otpVerify,
        ApiEvents.resendOtp,
        ApiEvents.pancard,
        ApiEvents.personalDetails,
        ApiEvents.residenceDetails,
        ApiEvents.incomeDetails,
        ApiEvents.employmentDetails,
        ApiEvents.bankingDetails,
        ApiEvents.selfieUpload,
        ApiEvents.pancardUpload,
        ApiEvents.aadhaarUpload,
        ApiEvents.residenceProof,
        ApiEvents.bankStatementUpload,
        ApiEvents.paySlipUpload,
        ApiEvents.registerNow,
        ApiEvents.generateLoanQuote,
        ApiEvents.loanQuotationDecision,
        ApiEvents.completed,
      ];

      for (final event in events) {
        expect(
          JourneyService.routeFor(event),
          isNotNull,
          reason: '$event has no route, so it would log the customer out',
        );
      }
    });

    test('an unknown step has no route', () {
      expect(JourneyService.routeFor('something_new'), isNull);
      expect(JourneyService.routeFor(null), isNull);
      expect(JourneyService.routeFor(''), isNull);
    });
  });

  group('isRegistered', () {
    test('is true for the screens that exist', () {
      for (final page in AppPages.routes) {
        expect(JourneyService.isRegistered(page.name), isTrue);
      }
    });

    test('is false for a route with no page', () {
      expect(JourneyService.isRegistered('/not-a-screen'), isFalse);
    });

    test('the step after OTP verification has somewhere to go', () {
      // The CRM answers otp_verify with next_step: pancard_verification.
      // Until that screen exists goToStep falls back to the dashboard —
      // what must never happen is the customer being left on the OTP
      // screen with nothing happening.
      final route = JourneyService.routeFor(ApiEvents.pancard);

      expect(route, isNotNull);
      // Either the screen is built, or the fallback covers it.
      expect(
        JourneyService.isRegistered(route!) ||
            JourneyService.isRegistered('/dashboard'),
        isTrue,
      );
    });
  });
}
