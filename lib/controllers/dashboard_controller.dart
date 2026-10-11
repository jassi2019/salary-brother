import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/api/api_endpoints.dart';
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

    if (!result.isSuccess) {
      // Status 4 means the CRM ended the session; Status 3 sends the customer
      // back to the dashboard, which is already where they are.
      if (result.shouldLogout) {
        await JourneyService.logout();
        return;
      }
      errorMessage.value = result.error ?? '';
      return;
    }

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
}
