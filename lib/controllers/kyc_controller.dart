import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api/api_endpoints.dart';
import '../services/api/api_events.dart';
import '../services/api_service.dart';
import '../services/journey_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../utils/validators.dart';
import '../widgets/app_toast.dart';

/// PAN verification — the first step the CRM asks for after OTP.
///
/// The CRM pulls the credit report from the PAN and the stated income, and
/// answers with the next step, so there is nothing to decide locally.
class KycController extends GetxController {
  final panController = TextEditingController();
  final incomeController = TextEditingController();

  final isSubmitting = false.obs;

  /// Bumped on every keystroke so the button's enabled state keeps up with
  /// the two plain TextEditingControllers.
  final formTick = 0.obs;

  String get pan => panController.text.trim().toUpperCase();

  String get income => incomeController.text.replaceAll(RegExp(r'[^0-9]'), '');

  bool get canSubmit =>
      Validators.pan(pan) == null && (int.tryParse(income) ?? 0) > 0;

  @override
  void onClose() {
    panController.dispose();
    incomeController.dispose();
    super.onClose();
  }

  void onFieldChanged() => formTick.value++;

  Future<void> submit() async {
    final panError = Validators.pan(pan);
    if (panError != null) {
      AppToast.error(panError);
      return;
    }
    if ((int.tryParse(income) ?? 0) <= 0) {
      AppToast.error('Enter your monthly income');
      return;
    }

    isSubmitting.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveCustomerProfile,
      event: ApiEvents.pancard,
      body: {
        'profile_id': StorageService.profileId ?? '',
        'pancard': pan,
        'monthly_income': income,
      },
    );
    isSubmitting.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      AppToast.error(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    await StorageService.setPancard(pan);
    await JourneyService.rememberStep(result.data);

    if (result.message != null) AppToast.success(result.message!);

    JourneyService.goToStep(result.data?['next_step']?.toString());
  }
}
