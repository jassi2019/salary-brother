import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/square_icon_button.dart';

/// Screen 02 of the design canvas — mobile number entry.
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

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
              const Text(
                'Verify your mobile number',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 10),
              const Text(
                "We'll text you a one-time password. Use the number linked "
                'to your bank account.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSizes.xxl),
              const Text('Mobile number', style: AppTextStyles.label),
              const SizedBox(height: AppSizes.s),
              _mobileField(),
              const Spacer(),
              _termsCheckbox(),
              const SizedBox(height: 18),
              Obx(
                () => PrimaryButton(
                  label: 'Send OTP',
                  isLoading: controller.isSendingOtp.value,
                  onPressed: controller.canSendOtp ? controller.sendOtp : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileField() {
    return Container(
      height: AppSizes.fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const Text(
            '+91',
            style: TextStyle(
              fontFamily: AppTextStyles.fontBody,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Container(width: 1, height: 24, color: AppColors.disabled),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: TextField(
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              autofocus: true,
              onChanged: (_) => controller.isSendingOtp.refresh(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '98765 43210',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsCheckbox() {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: controller.termsAccepted.value,
              onChanged: (value) =>
                  controller.termsAccepted.value = value ?? false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          const Expanded(
            child: Text(
              'I agree to the Terms and Privacy Policy, and allow Salary '
              'Brother and its lending partner to fetch my credit report.',
              style: TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 13,
                height: 1.55,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
