import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/primary_button.dart';
import '../widgets/square_icon_button.dart';

/// Screen 02b of the design canvas — the 6-digit OTP boxes.
class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            AppSizes.screenPadding,
            AppSizes.screenPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SquareIconButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Back',
                    background: AppColors.surface,
                    onPressed: Get.back<void>,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Need help?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xxl),
              const Text('Enter the OTP', style: AppTextStyles.h2),
              const SizedBox(height: 10),
              Text(
                'Sent to +91 ${Formatters.mobile(controller.mobile)}',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSizes.xxl),
              _otpHeader(),
              const SizedBox(height: AppSizes.m),
              _otpFields(),
              const SizedBox(height: AppSizes.m),
              _resendRow(),
              const Spacer(),
              Obx(
                () => PrimaryButton(
                  label: 'Verify & continue',
                  showIcon: false,
                  isLoading: controller.isVerifying.value,
                  onPressed:
                      controller.canVerify ? controller.verifyOtp : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Enter 6-digit OTP', style: AppTextStyles.label),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Auto-reading SMS',
              style: TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _otpFields() {
    return PinCodeTextField(
      appContext: Get.context!,
      length: 6,
      controller: controller.otpController,
      keyboardType: TextInputType.number,
      autoFocus: true,
      enableActiveFill: true,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 150),
      textStyle: AppTextStyles.otpDigit,
      // Keeps the Verify button in sync with what has been typed.
      onChanged: (_) => controller.isVerifying.refresh(),
      onCompleted: (_) => controller.verifyOtp(),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(AppSizes.radiusOtpBox),
        fieldHeight: AppSizes.otpBoxHeight,
        fieldWidth: 48,
        borderWidth: 1.5,
        activeColor: AppColors.primary,
        selectedColor: AppColors.primary,
        inactiveColor: AppColors.border,
        activeFillColor: AppColors.white,
        selectedFillColor: AppColors.white,
        inactiveFillColor: AppColors.surface,
      ),
    );
  }

  Widget _resendRow() {
    return Obx(() {
      final waiting = controller.resendSeconds.value > 0;

      return Row(
        children: [
          Text("Didn't get it? ", style: AppTextStyles.caption.copyWith(fontSize: 14)),
          if (waiting)
            Text(
              'Resend in ${controller.resendLabel}',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            )
          else
            GestureDetector(
              onTap: controller.sendOtp,
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontBody,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      );
    });
  }
}
