import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/route_names.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/brand_config.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_logo.dart';
import '../widgets/primary_button.dart';

/// Screen 01 of the design canvas — the welcome / hero screen.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            AppSizes.screenPadding,
            AppSizes.screenPadding,
            22,
          ),
          // No scroll view: the hero absorbs whatever height is left over, so
          // the screen always fits exactly once and never scrolls.
          child: Column(
            children: [
              const _WelcomeHeader(),
              const SizedBox(height: AppSizes.l),
              const Expanded(child: _Hero()),
              const SizedBox(height: AppSizes.l),
              const _TrustRow(),
              const SizedBox(height: AppSizes.l),
              PrimaryButton(
                label: 'Get started',
                onPressed: () => Get.toNamed(RouteNames.login),
              ),
              const SizedBox(height: AppSizes.s),
              _loginPrompt(),
              const SizedBox(height: AppSizes.s),
              // Capped: on a short screen the disclosure would otherwise
              // take height the hero needs. It is reachable in full from the
              // privacy policy.
              const Text(
                BrandConfig.lenderDisclosure,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.legal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginPrompt() {
    // Wrap, not Row: at a large system text scale the two pieces no longer
    // fit on one line and a Row would overflow.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(RouteNames.login),
          child: const Text(
            'Log in',
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
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    // The design has an EN/हिंदी toggle here. Dropped until the app is
    // actually translated — it had no handler and switched nothing.
    return const SizedBox(
      height: AppSizes.touchTarget,
      child: Row(
        children: [
          BrandLogo(),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      padding: const EdgeInsets.all(24),
      // Two stacked zones rather than one Stack with absolute offsets. The
      // cards used to be Positioned at fixed tops while the text was pinned
      // to the bottom of whatever height the hero got — so on a shorter
      // screen the text slid up underneath them. As siblings they cannot
      // overlap, whatever height the device gives.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Takes the slack on a tall screen and gives it back on a short
          // one; _FloatingCards scales itself to whatever it is handed.
          const Expanded(child: _FloatingCards()),
          const SizedBox(height: AppSizes.m),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: const Text('SALARY ADVANCE', style: AppTextStyles.pill),
          ),
          const SizedBox(height: AppSizes.m),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Your salary, a little early.',
              // h1 is near-black for light surfaces; on the plum hero it has
              // to be white or it reads at about 2:1 contrast.
              style: AppTextStyles.h1.copyWith(color: AppColors.white),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: AppSizes.s),
          Flexible(
            child: Text(
              'Short-term loans for salaried India. 100% digital — '
              'no paperwork, no collateral.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onPrimaryMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The two tilted cards at the top of the hero.
///
/// They overlap each other by design, but as a self-contained zone — the
/// headline below is never one of the things they can land on.
class _FloatingCards extends StatelessWidget {
  const _FloatingCards();

  /// Enough for the receipt plus the chip hanging off its lower right.
  static const double _height = 212;

  @override
  Widget build(BuildContext context) {
    // The hero has no scroll view, so on a short screen this zone is handed
    // less than it wants. Scale down to fit rather than overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        final scale =
            available.isFinite && available < _height ? available / _height : 1.0;

        return SizedBox(
          height: _height * scale,
          child: const FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: _height,
              width: 330,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(top: 0, left: 0, child: _CreditedCard()),
                  Positioned(bottom: 0, right: 0, child: _SalaryDayChip()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The tilted "credited to your bank" receipt floating over the hero.
class _CreditedCard extends StatelessWidget {
  const _CreditedCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.052,
      child: Container(
        width: 214,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D2A041C),
              blurRadius: 34,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSizes.iconBadge,
                  height: AppSizes.iconBadge,
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                // Expanded, or the label overflows the 214px card — it was
                // spilling past the card's right edge on a real device.
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Credited to your bank',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontBody,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text('₹20,000', style: AppTextStyles.amountMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 10),
            const Text(
              'HDFC Bank •••• 4521 · Just now',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }
}

/// The tilted "repay on salary day" chip floating over the hero.
class _SalaryDayChip extends StatelessWidget {
  const _SalaryDayChip();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.07,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(AppSizes.radiusCardSmall),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D2A041C),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 22,
              color: AppColors.primaryDeep,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Repay on',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDeep,
                  ),
                ),
                Text(
                  'Salary day',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontBody,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The three trust badges under the hero.
class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.verified_user_outlined, 'RBI-registered lender'),
      (Icons.bolt_rounded, '100% paperless'),
      (Icons.lock_outline_rounded, 'Data encrypted'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSizes.s),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              radius: AppSizes.radiusCardSmall,
              child: Column(
                children: [
                  Container(
                    width: AppSizes.iconBadge,
                    height: AppSizes.iconBadge,
                    decoration: BoxDecoration(
                      color: AppColors.tintSoft,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      items[i].$1,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontBody,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
