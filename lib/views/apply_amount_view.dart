import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/loan_controller.dart';
import '../routes/route_names.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/square_icon_button.dart';

/// Screen 04 of the design canvas — the live loan calculator.
class ApplyAmountView extends GetView<LoanController> {
  const ApplyAmountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose amount'),
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.screenPadding),
          child: SquareIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Back',
            onPressed: Get.back<void>,
          ),
        ),
        leadingWidth: 64,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.screenPadding),
            child: SquareIconButton(
              icon: Icons.help_outline_rounded,
              tooltip: 'Help',
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  18,
                  AppSizes.screenPadding,
                  AppSizes.screenPadding,
                ),
                children: const [
                  _AmountPicker(),
                  SizedBox(height: 18),
                  _TenurePicker(),
                  SizedBox(height: 18),
                  _QuoteBreakdown(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                0,
                AppSizes.screenPadding,
                24,
              ),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: () => Get.toNamed(RouteNames.kyc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The big amount readout, the +/- steppers, the slider and the presets.
class _AmountPicker extends StatelessWidget {
  const _AmountPicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    return AppCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Obx(() {
        final pricing = controller.pricing.value;

        return Column(
          children: [
            const Text('How much do you need?', style: AppTextStyles.label),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Decrease by ${Formatters.rupees(pricing.stepAmount)}',
                  filled: false,
                  onPressed: controller.amount.value > pricing.minAmount
                      ? controller.decrement
                      : null,
                ),
                Text(
                  Formatters.rupees(controller.amount.value),
                  style: AppTextStyles.amountLarge,
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Increase by ${Formatters.rupees(pricing.stepAmount)}',
                  filled: true,
                  onPressed: controller.amount.value < pricing.maxAmount
                      ? controller.increment
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Slider(
              value: controller.amount.value.toDouble(),
              min: pricing.minAmount.toDouble(),
              max: pricing.maxAmount.toDouble(),
              divisions: ((pricing.maxAmount - pricing.minAmount) /
                      pricing.stepAmount)
                  .round()
                  .clamp(1, 1000),
              label: Formatters.rupees(controller.amount.value),
              onChanged: (value) => controller.setAmount(value.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.rupees(pricing.minAmount),
                  style: AppTextStyles.smallBold.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  Formatters.rupees(pricing.maxAmount),
                  style: AppTextStyles.smallBold.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _presetRow(controller),
          ],
        );
      }),
    );
  }

  Widget _presetRow(LoanController controller) {
    final presets = controller.presets;

    return Row(
      children: [
        for (var i = 0; i < presets.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSizes.s),
          Expanded(
            child: _ChoiceChipButton(
              selected: controller.amount.value == presets[i],
              height: 40,
              onPressed: () => controller.setAmount(presets[i]),
              child: Text(
                presets[i] == controller.pricing.value.maxAmount
                    ? 'Max'
                    : Formatters.rupees(presets[i]),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontBody,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: controller.amount.value == presets[i]
                      ? Colors.white
                      : AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Repay in" — the four tenure buttons plus the due date.
class _TenurePicker extends StatelessWidget {
  const _TenurePicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    return Obx(() {
      final options = controller.pricing.value.tenureOptions;
      final quote = controller.quote;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Repay in', style: AppTextStyles.bodyBold),
              Row(
                children: [
                  const Text('Due on ', style: AppTextStyles.caption),
                  Text(
                    Formatters.date(quote.dueDate),
                    style: AppTextStyles.smallBold.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.s),
                Expanded(
                  child: _ChoiceChipButton(
                    selected: controller.days.value == options[i],
                    height: 56,
                    radius: AppSizes.radiusField,
                    onPressed: () => controller.setDays(options[i]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${options[i]}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: controller.days.value == options[i]
                                ? Colors.white
                                : AppColors.ink,
                          ),
                        ),
                        Text(
                          'days',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontBody,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: controller.days.value == options[i]
                                ? Colors.white
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }
}

/// The fee / GST / interest breakdown with the green "you get" strip.
class _QuoteBreakdown extends StatelessWidget {
  const _QuoteBreakdown();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    return Obx(() {
      final pricing = controller.pricing.value;
      final quote = controller.quote;

      return AppCard(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusField),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'You get in your bank',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B5C45),
                    ),
                  ),
                  Text(
                    Formatters.rupees(quote.netDisbursed),
                    style: AppTextStyles.amountMedium.copyWith(
                      color: const Color(0xFF0B5C45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            _Line(
              label: 'Processing fee '
                  '(${_trim(pricing.processingFeePct)}%)',
              value: Formatters.rupees(quote.processingFee),
            ),
            _Line(
              label: 'GST on fee (${_trim(pricing.gstPct)}%)',
              value: Formatters.rupees(quote.gst),
            ),
            _Line(
              label: 'Interest (${_trim(pricing.ratePerDay)}%/day '
                  '× ${quote.days} days)',
              value: Formatters.rupees(quote.interest),
            ),
            const SizedBox(height: 11),
            const Divider(color: AppColors.borderSoft),
            const SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('Total repayable', style: AppTextStyles.bodyBold),
                Text(
                  Formatters.rupees(quote.totalRepayable),
                  style: AppTextStyles.amountMedium.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.s),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'APR ${quote.aprLabel} · Full details in the Key Fact Statement',
                style: AppTextStyles.small,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 10.0 -> "10", 1.5 -> "1.5"
  String _trim(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontBody,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.filled,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: filled
                ? (enabled ? AppColors.primary : AppColors.disabled)
                : AppColors.surface,
            shape: CircleBorder(
              side: filled
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border, width: 1.5),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Icon(
                icon,
                size: 22,
                color: filled
                    ? Colors.white
                    : (enabled ? AppColors.primary : AppColors.disabled),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A selectable pill/box: plum when selected, white with a border when not.
class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.selected,
    required this.height,
    required this.child,
    required this.onPressed,
    this.radius = 12,
  });

  final bool selected;
  final double height;
  final Widget child;
  final VoidCallback onPressed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: SizedBox(
        height: height,
        child: Material(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(radius),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onPressed,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
