import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_text_field.dart';
import '../widgets/journey_scaffold.dart';
import '../widgets/primary_button.dart';

/// Step 4 — income, how it arrives and when.
///
/// The salary date matters: the loan is timed to it, so the repayment lands
/// the day the money does.
class IncomeDetailsView extends GetView<ProfileController> {
  const IncomeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return JourneyScaffold(
      title: 'Income',
      step: 4,
      totalSteps: 5,
      footer: Obx(() {
        controller.formTick.value;

        return PrimaryButton(
          label: 'Continue',
          isLoading: controller.isSubmitting.value,
          onPressed:
              controller.canSubmitIncome ? controller.submitIncome : null,
        );
      }),
      children: [
        const Text('Your income', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        const Text(
          'Your limit and your repayment date are set from this.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSizes.xxl),
        AppTextField(
          label: 'Monthly take-home salary',
          controller: controller.monthlyIncomeController,
          hint: '40,000',
          helper: 'What lands in your bank each month, after deductions',
          prefix: '₹',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => controller.onFieldChanged(),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'Income type',
            hint: 'Select',
            value: controller.incomeType.value.isEmpty
                ? null
                : controller.incomeType.value,
            items: ProfileController.incomeTypes,
            onChanged: (value) {
              controller.incomeType.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'How you are paid',
            hint: 'Select',
            value: controller.salaryMode.value.isEmpty
                ? null
                : controller.salaryMode.value,
            items: ProfileController.salaryModes,
            onChanged: (value) {
              controller.salaryMode.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        Obx(
          () => AppDropdownField<String>(
            label: 'Salary day',
            hint: 'Select',
            value: controller.salaryDay.value.isEmpty
                ? null
                : controller.salaryDay.value,
            items: _salaryDays,
            onChanged: (value) {
              controller.salaryDay.value = value ?? '';
              controller.onFieldChanged();
            },
          ),
        ),
      ],
    );
  }

  /// Days 1-31. Months are shorter than 31 days, but the CRM takes the day
  /// number and resolves it against the actual month.
  Map<String, String> get _salaryDays => {
        for (var day = 1; day <= 31; day++) '$day': _ordinal(day),
      };

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    return switch (day % 10) {
      1 => '${day}st',
      2 => '${day}nd',
      3 => '${day}rd',
      _ => '${day}th',
    };
  }
}
