import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../routes/route_names.dart';
import '../services/journey_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/avatar.dart';
import '../widgets/app_toast.dart';
import '../widgets/square_icon_button.dart';

/// Screen 03 of the design canvas — the home / dashboard screen.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadProfile,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: const [
              _Greeting(),
              SizedBox(height: 18),
              _LimitCard(),
              SizedBox(height: 18),
              _ProfileProgressCard(),
              SizedBox(height: 18),
              _QuickActions(),
              SizedBox(height: 18),
              _HowItWorks(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final user = controller.user.value;

      return Row(
        children: [
          Avatar(user: user, size: AppSizes.touchTarget, fontSize: 15),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greetingFor(DateTime.now()),
                    style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  user?.name ?? 'Welcome',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          // TODO: a notifications button belongs here once there is a
          // screen behind it. Support in the meantime, rather than an
          // enabled button that does nothing.
          SquareIconButton(
            icon: Icons.headset_mic_outlined,
            tooltip: 'Support',
            onPressed: () => Get.toNamed(RouteNames.support),
          ),
        ],
      );
    });
  }

  String _greetingFor(DateTime now) {
    if (now.hour < 12) return 'Good morning,';
    if (now.hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

/// The plum pre-approved-limit card with the "Get money now" button.
class _LimitCard extends StatelessWidget {
  const _LimitCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final pricing = controller.limit.value;
      final hasLimit = pricing != null;
      // Before the CRM issues a quote there is no limit to show, and the
      // button continues the application instead of opening a calculator
      // the server would refuse.
      final nextStep = controller.nextStep;

      return HeroCard(
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Your pre-approved limit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                ),
                if (hasLimit)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: const Text(
                      // TODO: show the real validity date from the backend.
                      'Pre-approved',
                      style: AppTextStyles.pill,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                hasLimit ? Formatters.rupees(pricing.maxAmount) : '—',
                maxLines: 1,
                style: AppTextStyles.amountHero,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              hasLimit
                  ? 'From ${Formatters.rupees(pricing.minAmount)} · Repay in '
                      '${pricing.tenureOptions.first}–'
                      '${pricing.tenureOptions.last} days'
                  : 'Finish your application to see your limit',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onPrimaryMuted,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusField),
                  ),
                ),
                onPressed: hasLimit
                    ? () => Get.toNamed(RouteNames.applyAmount)
                    : (nextStep.route == null
                        ? null
                        : () => Get.toNamed(nextStep.route!)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        hasLimit ? 'Get money now' : 'Continue application',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontBody,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// "Finish your profile" with the four-segment progress bar.
class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      if (controller.isProfileComplete) return const SizedBox.shrink();

      final done = controller.completedSteps;

      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Finish your profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
                const SizedBox(width: AppSizes.s),
                Text(
                  '$done of ${DashboardController.totalSteps} done',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontBody,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < DashboardController.totalSteps; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            i < done ? AppColors.primary : AppColors.borderSoft,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _nextStepTile(),
          ],
        ),
      );
    });
  }

  Widget _nextStepTile() {
    final controller = Get.find<DashboardController>();
    final step = controller.nextStep;
    final enabled = step.route != null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusField),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        // Null when the screen for this step is not built yet, which dims the
        // tile instead of letting it look tappable and do nothing.
        onTap: enabled ? () => Get.toNamed(step.route!) : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.m),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next: ${step.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontBody,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The four shortcut tiles: calculator, repay, history, support.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    // Repay and History have no screens yet. They stay on the grid so the
    // layout matches the design, but _QuickAction dims anything whose route
    // is not registered rather than letting it look tappable.
    final actions = <(IconData, String, String?)>[
      (Icons.calculate_outlined, 'Calculator', RouteNames.applyAmount),
      (Icons.replay_rounded, 'Repay', RouteNames.repay),
      (Icons.history_rounded, 'History', null),
      (Icons.headset_mic_outlined, 'Support', RouteNames.support),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: actions[i].$1,
              label: actions[i].$2,
              route: actions[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String? route;

  /// False when there is no screen behind this tile, or when the journey has
  /// not reached it yet. An enabled control that does nothing — or that opens
  /// a screen the server will refuse — reads as a broken app.
  bool get _enabled {
    if (route == null || !JourneyService.isRegistered(route!)) return false;
    // The calculator decides on a quote the CRM has not issued yet.
    if (route == RouteNames.applyAmount) return JourneyService.canChooseAmount;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _enabled ? label : '$label, coming soon',
      enabled: _enabled,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusCardSmall),
        onTap: _enabled ? () => Get.toNamed(route!) : null,
        // stretch, or the Column hands the tile a loose width and it shrinks
        // to the icon — at which point the 18px radius exceeds half the width
        // and the box renders as a tall capsule instead of a rounded square.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusCardSmall),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Icon(
                icon,
                size: 24,
                color: _enabled ? AppColors.primary : AppColors.disabled,
              ),
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _enabled ? AppColors.ink : AppColors.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tinted "Money in 3 simple steps" panel.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Choose amount & tenure',
      'Complete KYC online',
      'e-Sign & get money in bank',
    ];

    return AppCard(
      color: AppColors.tint,
      border: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Money in 3 simple steps',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s),
                      Text(
                        steps[i],
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontBody,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          // Without even leading the extra line height all
                          // goes above the text, and descenders on the last
                          // line get clipped.
                          leadingDistribution: TextLeadingDistribution.even,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const Map<int, String> _routes = {
    1: RouteNames.applyAmount,
    2: RouteNames.profile,
    3: RouteNames.support,
  };

  /// Home is already on screen, so tapping it only clears the highlight.
  /// The others push, then reset the bar when the customer comes back.
  Future<void> _openTab(DashboardController controller, int index) async {
    final route = _routes[index];
    if (route == null) {
      controller.tabIndex.value = 0;
      return;
    }

    // Apply opens the amount picker, which the CRM refuses before the quote
    // exists. Send the customer to the step they actually owe instead.
    if (route == RouteNames.applyAmount && !JourneyService.canChooseAmount) {
      controller.tabIndex.value = 0;
      final next = controller.nextStep.route;
      if (next != null) {
        await Get.toNamed(next);
      } else {
        AppToast.info('Finish your application to choose an amount');
      }
      return;
    }

    controller.tabIndex.value = index;
    await Get.toNamed(route);
    controller.tabIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      // Every tab goes somewhere that exists. Repay has no screen yet, so
      // its slot is the calculator until it does — rather than a tab that
      // does nothing when tapped.
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: (index) => _openTab(controller, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate_rounded),
              label: 'Apply',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic_outlined),
              activeIcon: Icon(Icons.headset_mic_rounded),
              label: 'Support',
            ),
          ],
        ),
      ),
    );
  }
}
