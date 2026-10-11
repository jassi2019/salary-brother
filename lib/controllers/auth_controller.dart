import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/route_names.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_events.dart';
import '../services/api_service.dart';
import '../services/journey_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../utils/validators.dart';

class AuthController extends GetxController {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  final isSendingOtp = false.obs;
  final isVerifying = false.obs;
  final termsAccepted = true.obs;

  /// Set from the login response's `cust_profile_id`; every later call needs it.
  final profileId = ''.obs;

  /// Seconds left before "Resend OTP" becomes tappable.
  final resendSeconds = 0.obs;
  Timer? _resendTimer;

  static const int _resendCooldown = 30;

  /// The CRM issues 4-digit OTPs.
  static const int otpLength = 4;

  String get mobile => mobileController.text.replaceAll(RegExp(r'\s+'), '');

  bool get canSendOtp =>
      Validators.mobile(mobile) == null && termsAccepted.value;

  bool get canVerify =>
      Validators.otp(otpController.text, length: otpLength) == null;

  @override
  void onClose() {
    _resendTimer?.cancel();
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> sendOtp() async {
    final error = Validators.mobile(mobile);
    if (error != null) {
      _toast(error);
      return;
    }
    if (!termsAccepted.value) {
      _toast('Please accept the Terms and Privacy Policy to continue');
      return;
    }

    isSendingOtp.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveCustomerProfile,
      event: ApiEvents.login,
      auth: AuthMode.login,
      body: {
        'mobile': mobile,
        'utm_source_test': StorageService.utmSource,
      },
    );
    isSendingOtp.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      _toast(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    final id = result.data?['cust_profile_id']?.toString();
    if (id == null || id.isEmpty) {
      // Without the profile id the OTP cannot be verified, so stop here
      // rather than opening a screen that is guaranteed to fail.
      _toast(AppStrings.somethingWentWrong);
      return;
    }

    profileId.value = id;
    await StorageService.setProfileId(id);

    if (result.message != null) _toast(result.message!);

    _startResendTimer();
    if (Get.currentRoute != RouteNames.otp) {
      Get.toNamed(RouteNames.otp);
    }
  }

  Future<void> resendOtp() async {
    if (resendSeconds.value > 0 || profileId.value.isEmpty) return;

    isSendingOtp.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveCustomerProfile,
      event: ApiEvents.resendOtp,
      auth: AuthMode.login,
      body: {
        'profile_id': profileId.value,
        'mobile': mobile,
      },
    );
    isSendingOtp.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      _toast(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    _startResendTimer();
  }

  Future<void> verifyOtp() async {
    final error = Validators.otp(otpController.text, length: otpLength);
    if (error != null) {
      _toast(error);
      return;
    }
    if (profileId.value.isEmpty) {
      _toast(AppStrings.somethingWentWrong);
      return;
    }

    isVerifying.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.saveCustomerProfile,
      event: ApiEvents.otpVerify,
      auth: AuthMode.login,
      body: {
        'profile_id': profileId.value,
        'otp': otpController.text,
        'fcm': StorageService.fcmToken ?? '',
      },
    );
    isVerifying.value = false;

    if (await JourneyService.handleRedirect(result)) return;

    if (!result.isSuccess) {
      _toast(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    final data = result.data ?? const <String, dynamic>{};
    final token = data['app_login_token']?.toString();
    if (token == null || token.isEmpty) {
      _toast(AppStrings.somethingWentWrong);
      return;
    }

    await StorageService.setToken(token);
    await StorageService.setMobile(mobile);
    await StorageService.setProfileId(profileId.value);
    await StorageService.setLoggedIn(true);

    final pancard = data['pancard']?.toString();
    if (pancard != null && pancard.isNotEmpty) {
      await StorageService.setPancard(pancard);
    }

    // The CRM decides where the customer goes next.
    final nextStep = data['next_step']?.toString() ?? '';
    if (nextStep.isNotEmpty) {
      await StorageService.setStepStage(nextStep);
    }

    _resendTimer?.cancel();
    if (result.message != null) _toast(result.message!);

    JourneyService.goToStep(nextStep);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = _resendCooldown;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  /// "00:24" for the resend hint.
  String get resendLabel {
    final s = resendSeconds.value;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:'
        '${(s % 60).toString().padLeft(2, '0')}';
  }

  void _toast(String message) =>
      Get.snackbar('', message, titleText: const SizedBox.shrink());
}
