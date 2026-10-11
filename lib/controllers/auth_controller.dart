import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/route_names.dart';
import '../services/api/api_endpoints.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import '../utils/validators.dart';

class AuthController extends GetxController {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  final isSendingOtp = false.obs;
  final isVerifying = false.obs;
  final termsAccepted = true.obs;

  /// Seconds left before "Resend OTP" becomes tappable.
  final resendSeconds = 0.obs;
  Timer? _resendTimer;

  static const int _resendCooldown = 30;

  String get mobile => mobileController.text.replaceAll(RegExp(r'\s+'), '');

  bool get canSendOtp =>
      Validators.mobile(mobile) == null && termsAccepted.value;

  bool get canVerify => Validators.otp(otpController.text) == null;

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
      ApiEndpoints.sendOtp,
      body: {'mobile': mobile},
    );
    isSendingOtp.value = false;

    if (!result.isSuccess) {
      _toast(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    _startResendTimer();
    if (Get.currentRoute != RouteNames.otp) {
      Get.toNamed(RouteNames.otp);
    }
  }

  Future<void> verifyOtp() async {
    final error = Validators.otp(otpController.text);
    if (error != null) {
      _toast(error);
      return;
    }

    isVerifying.value = true;
    final result = await ApiService.instance.post(
      ApiEndpoints.verifyOtp,
      body: {'mobile': mobile, 'otp': otpController.text},
    );
    isVerifying.value = false;

    if (!result.isSuccess) {
      _toast(result.error ?? AppStrings.somethingWentWrong);
      return;
    }

    final token = result.data?['token'] as String?;
    if (token == null || token.isEmpty) {
      _toast(AppStrings.somethingWentWrong);
      return;
    }

    await StorageService.setToken(token);
    await StorageService.setMobile(mobile);
    final userId = result.data?['user_id'];
    if (userId != null) {
      await StorageService.setUserId('$userId');
    }

    _resendTimer?.cancel();
    Get.offAllNamed(RouteNames.dashboard);
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
