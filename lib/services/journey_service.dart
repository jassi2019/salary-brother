import 'package:get/get.dart';

import '../routes/app_pages.dart';
import '../routes/route_names.dart';
import 'api/api_events.dart';
import 'api/api_result.dart';
import '../widgets/app_toast.dart';
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

    // A step whose screen is not built yet maps to a route GetX cannot
    // resolve, and Get.offAllNamed on an unregistered name does nothing —
    // leaving the customer staring at the screen they just finished. Send
    // them to the dashboard instead, so the journey always moves.
    if (!isRegistered(route)) {
      Get.offAllNamed(RouteNames.dashboard);
      return;
    }

    // A binding that throws would otherwise take the navigation down with it
    // and strand the customer on the screen they just finished. The dashboard
    // is always reachable, so fall back to it rather than going nowhere.
    try {
      if (route == RouteNames.documents) {
        Get.offAllNamed(
          route,
          arguments: {'isSelfie': event == ApiEvents.selfieUpload},
        );
        return;
      }

      Get.offAllNamed(route);
    } catch (_) {
      Get.offAllNamed(RouteNames.dashboard);
    }
  }

  /// Whether [route] has a page registered for it.
  static bool isRegistered(String route) =>
      AppPages.routes.any((page) => page.name == route);

  /// Opens the screen for the step stored from the last response. Used on
  /// launch to resume a half-finished application.
  static void resume() => goToStep(StorageService.stepStage);

  /// Acts on a `Status` that asks for a redirect: `4` logs out, `3` returns
  /// the customer to the dashboard.
  ///
  /// Returns true if it navigated, so callers can stop instead of also
  /// showing an error:
  ///
  /// ```dart
  /// if (await JourneyService.handleRedirect(result)) return;
  /// if (!result.isSuccess) { showError(result.error); return; }
  /// ```
  static Future<bool> handleRedirect(ApiResult<dynamic> result) async {
    if (result.shouldLogout) {
      await logout();
      return true;
    }

    if (result.shouldBounceToDashboard) {
      // Already on the dashboard: nothing to do, and re-pushing it would
      // drop whatever the customer was told.
      if (Get.currentRoute == RouteNames.dashboard) return false;
      Get.offAllNamed(RouteNames.dashboard);
      return true;
    }

    return false;
  }

  /// Stores the CRM's `next_step` from a response payload, if it carried one.
  static Future<void> rememberStep(Map<String, dynamic>? data) async {
    final next = data?['next_step']?.toString() ?? '';
    if (next.isNotEmpty) await StorageService.setStepStage(next);
  }

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

  /// The profile id, or null when the session has lost it.
  ///
  /// Every post-OTP call needs it. Sending an empty string instead makes the
  /// CRM reject the request and the customer sees a generic error with no
  /// hint that their session is the problem — so callers use this and log out
  /// cleanly when it is missing.
  static Future<String?> requireProfileId() async {
    final id = StorageService.profileId;
    if (id != null && id.isNotEmpty) return id;

    AppToast.error('Your session has expired. Please log in again.');
    await logout();
    return null;
  }
}
