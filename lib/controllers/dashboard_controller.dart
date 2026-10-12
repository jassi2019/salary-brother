import 'package:get/get.dart';

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
    if (data != null && data.isNotEmpty) {
      user.value = UserModel.fromJson(data);
    }
  }

  /// Steps shown in the "Finish your profile" card.
  int get completedSteps => switch (user.value?.stage) {
        null => 0,
        KycStage.mobileVerified => 1,
        KycStage.personalDetails => 2,
        KycStage.panVerified => 3,
        KycStage.aadhaarVerified => 3,
        KycStage.bankLinked => 4,
        KycStage.complete => 4,
      };

  static const int totalSteps = 4;

  bool get isProfileComplete => user.value?.isKycComplete ?? false;

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
}
