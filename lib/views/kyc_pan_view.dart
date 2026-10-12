import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/kyc_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/brand_config.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/journey_scaffold.dart';
import '../widgets/primary_button.dart';

/// Screen 05 — PAN and monthly income.
///
/// The first step the CRM asks for after the OTP. It uses the PAN to pull the
/// credit report, so the screen says so plainly rather than asking for it
/// without explanation.
class KycPanView extends GetView<KycController> {
  const KycPanView({super.key});

  @override
  Widget build(BuildContext context) {
    return JourneyScaffold(
      title: 'PAN details',
      step: 1,
      totalSteps: 5,
      footer: Obx(() {
        // Read so the button re-evaluates on each keystroke.
        controller.formTick.value;

        return PrimaryButton(
          label: 'Continue',
          isLoading: controller.isSubmitting.value,
          onPressed: controller.canSubmit ? controller.submit : null,
        );
      }),
      children: [
        const Text('Your PAN', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        const Text(
          'We use it to check your credit report. This is a soft check and '
          'does not affect your score.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSizes.xxl),
        AppTextField(
          label: 'PAN number',
          controller: controller.panController,
          hint: 'ABCDE1234F',
          helper: 'Ten characters, as printed on your PAN card',
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            TextInputFormatter.withFunction(
              (_, next) => next.copyWith(text: next.text.toUpperCase()),
            ),
          ],
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'Monthly take-home salary',
          controller: controller.incomeController,
          hint: '40,000',
          helper: 'What lands in your bank each month, after deductions',
          prefix: '₹',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        _consentNote(),
      ],
    );
  }

  Widget _consentNote() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.tintSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Your PAN is encrypted and shared only with our lending '
                    'partner. See the ',
                style: AppTextStyles.small.copyWith(height: 1.5),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: _openPrivacyPolicy,
                      child: Text(
                        'privacy policy',
                        style: AppTextStyles.small.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the policy in the browser. There is no in-app privacy screen, and
  /// the route constant for one is not registered — routing to it silently
  /// did nothing, on a consent notice where the link is load-bearing.
  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(BrandConfig.privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.error('Could not open the privacy policy');
    }
  }
}
