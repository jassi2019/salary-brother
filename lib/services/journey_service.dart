import 'package:get/get.dart';

import '../routes/route_names.dart';
import 'api/api_events.dart';
import 'storage_service.dart';

/// Server-driven navigation.
///
/// The CRM, not the app, decides where the customer goes next: every response
/// carries `Data.next_step`, an `event_name` naming the step still to be done.
/// [goToStep] maps that to a route.
///
/// Anything unrecognised logs the customer out rather than guessing, which is
/// how the CRM expects an unknown state to be handled.
class JourneyService {
  JourneyService._();

  /// Route for [event], or null if the CRM sent something we do not handle.
  static String? routeFor(String? event) => switch (event) {
        ApiEvents.login ||
        ApiEvents.otpVerify ||
        ApiEvents.resendOtp =>
          RouteNames.login,
        ApiEvents.pancard => RouteNames.kycPan,
        ApiEvents.personalDetails => RouteNames.personalDetails,
        ApiEvents.residenceDetails => RouteNames.residenceDetails,
        ApiEvents.incomeDetails => RouteNames.incomeDetails,
        ApiEvents.employmentDetails => RouteNames.employmentDetails,
        ApiEvents.bankingDetails => RouteNames.bankDetails,
        ApiEvents.selfieUpload => RouteNames.documents,
        ApiEvents.pancardUpload ||
        ApiEvents.aadhaarUpload ||
        ApiEvents.residenceProof ||
        ApiEvents.bankStatementUpload ||
        ApiEvents.paySlipUpload =>
          RouteNames.documents,
        ApiEvents.registerNow => RouteNames.review,
        ApiEvents.generateLoanQuote => RouteNames.success,
        ApiEvents.loanQuotationDecision => RouteNames.applyAmount,
        ApiEvents.completed => RouteNames.dashboard,
        _ => null,
      };

  /// Sends the customer to the screen [event] calls for, clearing the stack.
  ///
  /// `selfie_upload` opens the document screen in selfie mode; the other
  /// upload events open it in general mode.
  static void goToStep(String? event) {
    final route = routeFor(event);

    if (route == null) {
      logout();
      return;
    }

    if (route == RouteNames.documents) {
      Get.offAllNamed(
        route,
        arguments: {'isSelfie': event == ApiEvents.selfieUpload},
      );
      return;
    }

    Get.offAllNamed(route);
  }

  /// Opens the screen for the step stored from the last response. Used on
  /// launch to resume a half-finished application.
  static void resume() => goToStep(StorageService.stepStage);

  /// How far the customer has got, for progress indicators.
  static int get currentPosition =>
      ApiEvents.positionOf(StorageService.stepStage);

  static bool get isApplicationComplete =>
      ApiEvents.isComplete(StorageService.stepStage);

  /// Clears the session and returns to login. Called on `Status: 4` and on any
  /// step the app does not recognise.
  static Future<void> logout() async {
    await StorageService.clearSession();
    Get.offAllNamed(RouteNames.login);
  }
}
