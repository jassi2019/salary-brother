import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../controllers/auth_controller.dart';
import '../routes/route_names.dart';
import '../services/sms_config.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../utils/sms_retriever_impl.dart';
import '../widgets/primary_button.dart';
import '../widgets/square_icon_button.dart';

/// Screen 02b of the design canvas — the OTP boxes.
class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  AuthController get controller => Get.find<AuthController>();

  late final SmsRetrieverImpl _smsRetriever;

  @override
  void initState() {
    super.initState();
    _smsRetriever = SmsRetrieverImpl(SmartAuth());
    // Pinput drives the listener; this only tells the UI it may promise
    // auto-fill.
    controller.isAutoReadingSms.value = true;
  }

  @override
  void dispose() {
    controller.isAutoReadingSms.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // Same as the login screen: the keyboard does not resize the body, so
      // there is nothing to squeeze and nothing to scroll.
      resizeToAvoidBottomInset: false,
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
                    onPressed: () => Get.toNamed(RouteNames.support),
                    child: const Text('Need help?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xxl),
              const Text('Enter the OTP', style: AppTextStyles.h2),
              const SizedBox(height: 10),
              Text(
                'Sent to +91 ${Formatters.mobile(controller.mobile)}. '
                'It expires in '
                '${SmsConfig.otpValidity.inMinutes} minutes.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSizes.xxl),
              _otpHeader(),
              const SizedBox(height: AppSizes.m),
              _otpFields(),
              const SizedBox(height: AppSizes.m),
              _resendRow(),
              const Spacer(),
              const SizedBox(height: AppSizes.xxl),
              Obx(
                () => PrimaryButton(
                  label: 'Verify & continue',
                  showIcon: false,
                  isLoading: controller.isVerifying.value,
                  onPressed: controller.canVerify ? controller.verifyOtp : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpHeader() {
    // Wrap, not Row: the label and the auto-read chip together are wider
    // than a narrow screen once the chip is showing.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSizes.s,
      runSpacing: AppSizes.xs,
      children: [
        const Text(
          'Enter ${AuthController.otpLength}-digit OTP',
          style: AppTextStyles.label,
        ),
        // Only claim auto-fill while something is actually listening.
        Obx(
          () => controller.isAutoReadingSms.value
              ? Row(
                  mainAxisSize: MainAxisSize.min,
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
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _otpFields() {
    return LayoutBuilder(
      builder: (context, constraints) => _pinput(_boxWidth(constraints)),
    );
  }

  Widget _pinput(double boxWidth) {
    final base = PinTheme(
      width: boxWidth,
      height: AppSizes.otpBoxHeight,
      textStyle: AppTextStyles.otpDigit,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusOtpBox),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );

    return Pinput(
      length: AuthController.otpLength,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      controller: controller.otpController,
      keyboardType: TextInputType.number,
      autofocus: true,
      // Fills the boxes from the incoming SMS via the User Consent API.
      smsRetriever: _smsRetriever,
      defaultPinTheme: base,
      focusedPinTheme: base.copyWith(
        decoration: base.decoration!.copyWith(
          color: AppColors.white,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
      ),
      submittedPinTheme: base.copyWith(
        decoration: base.decoration!.copyWith(
          color: AppColors.white,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
      ),
      // Keeps the Verify button in sync with what has been typed.
      onChanged: (_) => controller.isVerifying.refresh(),
      // Submits as soon as the code is complete, typed or auto-filled, so
      // nobody has to press Verify themselves.
      onCompleted: (_) => controller.verifyOtp(),
    );
  }

  /// Box width that fits [AuthController.otpLength] boxes plus their gaps in
  /// the width actually available, capped so they are not stretched wide on
  /// a tablet.
  double _boxWidth(BoxConstraints constraints) {
    const gap = 12.0;
    const maxWidth = 64.0;
    const minWidth = 36.0;

    if (!constraints.hasBoundedWidth) return maxWidth;

    final usable =
        constraints.maxWidth - (gap * (AuthController.otpLength - 1));

    return (usable / AuthController.otpLength).clamp(minWidth, maxWidth);
  }

  Widget _resendRow() {
    return Obx(() {
      final waiting = controller.resendSeconds.value > 0;

      // Wrap, not Row: two unbounded texts side by side overflow at a large
      // text scale, and inside IntrinsicHeight that assert takes the whole
      // screen down to blank white.
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Didn't get it? ",
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
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
              onTap: controller.resendOtp,
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
