import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/route_names.dart';
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
        // The keyboard takes ~300px. Without a scroll view the Column's
        // Spacer collapses, the content overflows and the field's text is
        // laid out off-screen — which looked like the digits not appearing
        // until the keyboard was dismissed.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
              child: IntrinsicHeight(
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
                          onPressed: _goBack,
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(RouteNames.support),
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
                      "We'll text you a one-time password. Use the number "
                      'linked to your bank account.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: AppSizes.xxl),
                    const Text('Mobile number', style: AppTextStyles.label),
                    const SizedBox(height: AppSizes.s),
                    _mobileField(),
                    const Spacer(),
                    const SizedBox(height: AppSizes.xxl),
                    _termsCheckbox(),
                    const SizedBox(height: 18),
                    Obx(
                      () => PrimaryButton(
                        label: 'Send OTP',
                        isLoading: controller.isSendingOtp.value,
                        onPressed:
                            controller.canSendOtp ? controller.sendOtp : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Leaves the login screen.
  ///
  /// Login is sometimes pushed on top of welcome and sometimes made the root
  /// route (after a logout, or when the CRM's step is unrecognised). On a root
  /// route `Get.back` is a no-op and the chevron looks broken, so fall back to
  /// the welcome screen.
  void _goBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back<void>();
    } else {
      Get.offAllNamed(RouteNames.welcome);
    }
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
