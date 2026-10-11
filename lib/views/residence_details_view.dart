import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/journey_scaffold.dart';
import '../widgets/primary_button.dart';

/// Step 3 — where the applicant lives.
class ResidenceDetailsView extends GetView<ProfileController> {
  const ResidenceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return JourneyScaffold(
      title: 'Address',
      step: 3,
      totalSteps: 5,
      footer: Obx(() {
        controller.formTick.value;

        return PrimaryButton(
          label: 'Continue',
          isLoading: controller.isSubmitting.value,
          onPressed:
              controller.canSubmitResidence ? controller.submitResidence : null,
        );
      }),
      children: [
        const Text('Where you live', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        const Text(
          'Your current address, not your permanent one.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSizes.xxl),
        AppTextField(
          label: 'Flat, house or building',
          controller: controller.addressLine1Controller,
          hint: 'C2/13, Second Floor',
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'Area or locality',
          controller: controller.addressLine2Controller,
          hint: 'Ashok Vihar Phase 2',
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'Landmark',
          controller: controller.landmarkController,
          hint: 'Near the metro station',
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'PIN code',
          controller: controller.pincodeController,
          hint: '110088',
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'You live here as',
            hint: 'Select',
            value: controller.residenceType.value.isEmpty
                ? null
                : controller.residenceType.value,
            items: ProfileController.residenceTypes,
            onChanged: (value) {
              controller.residenceType.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
      ],
    );
  }
}
