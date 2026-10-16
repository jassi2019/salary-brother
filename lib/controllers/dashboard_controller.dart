import 'package:get/get.dart';

import '../models/loan_quote.dart';
import '../models/user_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_events.dart';
import '../services/journey_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final user = Rxn<UserModel>();

  /// Which bottom-nav tab is showing.
  final tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await ApiService.instance.post(
      ApiEndpoints.getDashboardData,
      body: {'profile_id': StorageService.profileId ?? ''},
    );
    isLoading.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      errorMessage.value = result.error ?? '';
      return;
    }

    await JourneyService.rememberStep(result.data);

    final data = result.data;
    if (data == null || data.isEmpty) {
      // A success with nothing in it means the parse found nothing to read,
      // which would otherwise leave stale data on screen with no error.
      errorMessage.value = 'Could not load your details. Pull to refresh.';
      return;
    }

    final parsed = UserModel.fromJson(data);
    user.value = parsed;

    // The CRM's own next_event_name is more current than the step we stored
    // from the last write.
    final next = parsed.nextEvent;
    if (next != null && next.isNotEmpty) {
      await StorageService.setStepStage(next);
    }

    await loadLimit();
  }

  /// How far along the application is, 0-100, as the CRM computes it.
  int get progressPercent => user.value?.progressPercent ?? 0;

  /// The progress bar's filled segments, out of [totalSteps].
  int get completedSteps =>
      (progressPercent / 100 * totalSteps).floor().clamp(0, totalSteps);

  static const int totalSteps = 4;

  bool get isProfileComplete => user.value?.isComplete ?? false;

  Future<void> logout() async {
    await StorageService.clearSession();
  }

  /// What the CRM says the customer must do next, as a label and a route.
  ///
  /// The dashboard used to hardcode "Aadhaar e-KYC" and send every tap to the
  /// PAN screen, which the customer had usually already finished — the CRM
  /// bounced them straight back, so the tile read as dead.
  ({String title, String subtitle, String? route}) get nextStep {
    final step = StorageService.stepStage;
    final route = JourneyService.routeFor(step);

    final (title, subtitle) = switch (step) {
      ApiEvents.pancard => ('PAN verification', 'Takes about a minute'),
      ApiEvents.personalDetails => ('Personal details', 'Name, date of birth'),
      ApiEvents.residenceDetails => ('Your address', 'Where you live now'),
      ApiEvents.incomeDetails => ('Income details', 'Salary and salary day'),
      ApiEvents.employmentDetails => ('Employment details', 'Where you work'),
      ApiEvents.bankingDetails => ('Bank account', 'Where the money lands'),
      ApiEvents.selfieUpload => ('Selfie', 'A quick photo of you'),
      ApiEvents.aadhaarUpload => ('Aadhaar e-KYC', 'Paperless, via DigiLocker'),
      ApiEvents.pancardUpload => ('Upload your PAN', 'A photo of the card'),
      ApiEvents.residenceProof => ('Address proof', 'A utility bill works'),
      ApiEvents.bankStatementUpload =>
        ('Bank statement', 'Last three months'),
      ApiEvents.paySlipUpload => ('Pay slips', 'Last three months'),
      ApiEvents.registerNow => ('Review and submit', 'Check your details'),
      ApiEvents.generateLoanQuote => ('Your offer', 'See what you qualify for'),
      ApiEvents.loanQuotationDecision =>
        ('Choose your amount', 'Pick an amount and a tenure'),
      _ => ('Finish your application', 'Pick up where you left off'),
    };

    // Only offer the tap if the screen for that step actually exists.
    final usable = route != null && JourneyService.isRegistered(route);

    return (title: title, subtitle: subtitle, route: usable ? route : null);
  }

  /// The sanctioned limit, once the CRM has issued a quote.
  ///
  /// It does NOT come from `getDashboardData` — it is the answer to a
  /// separate `generate_loan_quote` post, so the dashboard asks for it only
  /// once registration is complete. Null means no quote yet, which is a
  /// different thing from a limit of zero.
  final limit = Rxn<LoanPricing>();

  final isLoadingLimit = false.obs;

  /// Asks the CRM for the customer's quote. Safe to call when it is not due:
  /// it returns without posting.
  Future<void> loadLimit() async {
    final profile = user.value;
    if (profile == null || !profile.isRegistered) return;

    final profileId = StorageService.profileId ?? '';
    if (profileId.isEmpty) return;

    isLoadingLimit.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveLeadDetails,
      event: ApiEvents.generateLoanQuote,
      body: {'profile_id': profileId},
    );
    isLoadingLimit.value = false;

    // A quote that is not ready is not an error worth showing: the dashboard
    // simply has no limit to display yet.
    if (!result.isSuccess || result.data == null) return;

    limit.value = LoanPricing.fromJson(result.data!);
  }

  /// True once the CRM has sanctioned an amount the customer can draw.
  bool get hasLimit => limit.value != null;
}
