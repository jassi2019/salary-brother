import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/route_names.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import 'square_icon_button.dart';

/// The shared frame for the application steps: a header with the step
/// progress, scrolling content, and a pinned footer button.
///
/// These screens scroll — unlike login and OTP, they have more fields than
/// fit beside a keyboard — so the keyboard is allowed to resize the body and
/// the content moves out from under it.
class JourneyScaffold extends StatelessWidget {
  const JourneyScaffold({
    super.key,
    required this.title,
    required this.children,
    required this.footer,
    this.step,
    this.totalSteps,
    this.onBack,
  });

  final String title;
  final List<Widget> children;

  /// Pinned above the keyboard, clear of the scrolling content.
  final Widget footer;

  /// 1-based position in the application, for the progress bar.
  final int? step;
  final int? totalSteps;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            if (step != null && totalSteps != null) _progress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  AppSizes.xl,
                  AppSizes.screenPadding,
                  AppSizes.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                AppSizes.s,
                AppSizes.screenPadding,
                AppSizes.l,
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.m,
        AppSizes.screenPadding,
        0,
      ),
      child: Row(
        children: [
          SquareIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Back',
            background: AppColors.surface,
            onPressed: onBack ?? _defaultBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.appBarTitle,
            ),
          ),
          SquareIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: 'Help',
            onPressed: () => Get.toNamed(RouteNames.support),
          ),
        ],
      ),
    );
  }

  /// The CRM owns the journey, so back does not undo a step — it returns to
  /// the dashboard rather than popping to a screen the server has moved past.
  void _defaultBack() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back<void>();
    } else {
      Get.offAllNamed(RouteNames.dashboard);
    }
  }

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.l,
        AppSizes.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < totalSteps!; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < step!
                          ? AppColors.primary
                          : AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.s),
          Text('Step $step of $totalSteps', style: AppTextStyles.small),
        ],
      ),
    );
  }
}
