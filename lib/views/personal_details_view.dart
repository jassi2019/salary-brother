import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/journey_scaffold.dart';
import '../widgets/primary_button.dart';

/// Step 2 — name, email, date of birth, gender and marital status.
class PersonalDetailsView extends GetView<ProfileController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return JourneyScaffold(
      title: 'Personal details',
      step: 2,
      totalSteps: 5,
      footer: Obx(() {
        controller.formTick.value;

        return PrimaryButton(
          label: 'Continue',
          isLoading: controller.isSubmitting.value,
          onPressed:
              controller.canSubmitPersonal ? controller.submitPersonal : null,
        );
      }),
      children: [
        const Text('About you', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        const Text(
          'As it appears on your PAN, so the verification matches.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSizes.xxl),
        AppTextField(
          label: 'Full name',
          controller: controller.nameController,
          hint: 'Rahul Kumar',
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'Email address',
          controller: controller.emailController,
          hint: 'rahul@example.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        AppTextField(
          label: 'Date of birth',
          controller: controller.dobController,
          hint: 'Select your date of birth',
          readOnly: true,
          onTap: () => controller.pickDateOfBirth(context),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'Gender',
            hint: 'Select',
            value: controller.gender.value.isEmpty
                ? null
                : controller.gender.value,
            items: ProfileController.genders,
            onChanged: (value) {
              controller.gender.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'Marital status',
            hint: 'Select',
            value: controller.maritalStatus.value.isEmpty
                ? null
                : controller.maritalStatus.value,
            items: ProfileController.maritalStatuses,
            onChanged: (value) {
              controller.maritalStatus.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
        // The CRM requires the spouse's details once married is chosen.
        Obx(
          () => controller.isMarried
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.xl),
                    AppTextField(
                      label: "Spouse's name",
                      controller: controller.spouseNameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => controller.onFieldChanged(),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    AppTextField(
                      label: "Spouse's mobile number",
                      controller: controller.spouseMobileController,
                      prefix: '+91',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => controller.onFieldChanged(),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
