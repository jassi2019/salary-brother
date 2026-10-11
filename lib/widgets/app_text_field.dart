import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';

/// A labelled text field in the app's style.
///
/// Matches the login screen's mobile field: a tinted box with a hairline
/// border that turns plum on focus.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.prefix,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// Small note under the field, for format hints.
  final String? helper;

  /// Fixed text before the input, such as `₹`.
  final String? prefix;

  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  /// For fields opened by a picker rather than typed into.
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSizes.s),
        Container(
          height: AppSizes.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusField),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(
                  prefix!,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: AppSizes.m),
                Container(width: 1, height: 24, color: AppColors.disabled),
                const SizedBox(width: AppSizes.m),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  inputFormatters: inputFormatters,
                  maxLength: maxLength,
                  onChanged: onChanged,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: hint,
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
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: AppTextStyles.small),
        ],
      ],
    );
  }
}

/// A labelled dropdown in the same style as [AppTextField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSizes.s),
        Container(
          height: AppSizes.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusField),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint == null
                  ? null
                  : Text(
                      hint!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontBody,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedLight,
                      ),
                    ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.muted,
              ),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusField),
              onChanged: onChanged,
              items: [
                for (final entry in items.entries)
                  DropdownMenuItem<T>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
