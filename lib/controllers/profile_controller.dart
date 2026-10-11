import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/api/api_endpoints.dart';
import '../services/api/api_events.dart';
import '../services/api_service.dart';
import '../services/journey_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../utils/validators.dart';
import '../widgets/app_toast.dart';

/// The three profile steps the CRM asks for after PAN: personal, residence
/// and income details.
///
/// They share a controller because they share the same profile id and post to
/// the same endpoint, differing only in `event_name` and the fields sent.
class ProfileController extends GetxController {
  // --- personal -----------------------------------------------------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final spouseNameController = TextEditingController();
  final spouseMobileController = TextEditingController();

  /// `1` male, `2` female, as the CRM numbers them.
  final gender = ''.obs;

  /// `1` single, `2` married.
  final maritalStatus = ''.obs;

  // --- residence ----------------------------------------------------------
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final landmarkController = TextEditingController();
  final pincodeController = TextEditingController();

  /// `1` owned, `2` rented, `3` family-owned.
  final residenceType = ''.obs;

  // --- income -------------------------------------------------------------
  final monthlyIncomeController = TextEditingController();

  /// `1` salaried, `2` self-employed.
  final incomeType = ''.obs;

  /// `1` bank transfer, `2` cheque, `3` cash.
  final salaryMode = ''.obs;

  /// Day of the month the salary lands, as a plain number. Observable so
  /// the picker can rebuild — the text controller alone is not.
  final salaryDay = ''.obs;

  final isSubmitting = false.obs;

  /// Bumped on every keystroke so buttons track the plain text controllers.
  final formTick = 0.obs;

  static const Map<String, String> genders = {'1': 'Male', '2': 'Female'};

  static const Map<String, String> maritalStatuses = {
    '1': 'Single',
    '2': 'Married',
  };

  static const Map<String, String> residenceTypes = {
    '1': 'Owned',
    '2': 'Rented',
    '3': 'Family owned',
  };

  static const Map<String, String> incomeTypes = {
    '1': 'Salaried',
    '2': 'Self-employed',
  };

  static const Map<String, String> salaryModes = {
    '1': 'Bank transfer',
    '2': 'Cheque',
    '3': 'Cash',
  };

  @override
  void onClose() {
    for (final c in [
      nameController,
      emailController,
      dobController,
      spouseNameController,
      spouseMobileController,
      addressLine1Controller,
      addressLine2Controller,
      landmarkController,
      pincodeController,
      monthlyIncomeController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  void onFieldChanged() => formTick.value++;

  bool get isMarried => maritalStatus.value == '2';

  // --- personal -----------------------------------------------------------

  bool get canSubmitPersonal {
    final base = nameController.text.trim().length >= 3 &&
        Validators.email(emailController.text) == null &&
        dobController.text.isNotEmpty &&
        gender.value.isNotEmpty &&
        maritalStatus.value.isNotEmpty;

    if (!base) return false;
    if (!isMarried) return true;

    // The CRM wants both spouse fields once married is chosen.
    if (spouseNameController.text.trim().length < 3) return false;
    if (Validators.mobile(spouseMobileController.text) != null) return false;

    // The same-number check needs storage; submit() re-checks it and
    // refuses, so an unavailable store must not block the button.
    if (!StorageService.isReady) return true;
    return spouseMobileController.text.trim() != StorageService.mobile;
  }

  Future<void> submitPersonal() async {
    if (isMarried &&
        spouseMobileController.text.trim() == StorageService.mobile) {
      AppToast.error("Spouse's number cannot be the same as yours");
      return;
    }

    await _post(
      event: ApiEvents.personalDetails,
      body: {
        'first_name': nameController.text.trim(),
        'personal_email': emailController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': gender.value,
        'marital_status_id': maritalStatus.value,
        'spouse_name': isMarried ? spouseNameController.text.trim() : '',
        'spouse_mobile': isMarried ? spouseMobileController.text.trim() : '',
      },
    );
  }

  // --- residence ----------------------------------------------------------

  bool get canSubmitResidence =>
      addressLine1Controller.text.trim().length >= 5 &&
      pincodeController.text.trim().length == 6 &&
      residenceType.value.isNotEmpty;

  Future<void> submitResidence() => _post(
        event: ApiEvents.residenceDetails,
        body: {
          'residence_address_1': addressLine1Controller.text.trim(),
          'residence_address_2': addressLine2Controller.text.trim(),
          'residence_landmark': landmarkController.text.trim(),
          'residence_pincode': pincodeController.text.trim(),
          'residence_type_id': residenceType.value,
        },
      );

  // --- income -------------------------------------------------------------

  String get income =>
      monthlyIncomeController.text.replaceAll(RegExp(r'[^0-9]'), '');

  bool get canSubmitIncome =>
      (int.tryParse(income) ?? 0) > 0 &&
      incomeType.value.isNotEmpty &&
      salaryMode.value.isNotEmpty &&
      salaryDay.value.isNotEmpty;

  Future<void> submitIncome() => _post(
        event: ApiEvents.incomeDetails,
        body: {
          'monthly_income': income,
          'income_type_id': incomeType.value,
          'salary_mode_id': salaryMode.value,
          'salary_date': salaryDay.value,
        },
      );

  // --- shared -------------------------------------------------------------

  /// Posts one step and follows the CRM to whatever it says comes next.
  Future<void> _post({
    required String event,
    required Map<String, dynamic> body,
  }) async {
    isSubmitting.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveCustomerProfile,
      event: event,
      body: {'profile_id': StorageService.profileId ?? '', ...body},
    );
    isSubmitting.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      AppToast.error(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    await JourneyService.rememberStep(result.data);
    if (result.message != null) AppToast.success(result.message!);

    JourneyService.goToStep(result.data?['next_step']?.toString());
  }

  /// Opens a date picker for the date of birth, bounded to applicants between
  /// 18 and 70.
  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final oldest = DateTime(now.year - 70, now.month, now.day);
    final youngest = DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: oldest,
      lastDate: youngest,
      helpText: 'Date of birth',
    );

    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      onFieldChanged();
    }
  }
}
