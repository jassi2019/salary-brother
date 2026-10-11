import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../routes/route_names.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
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
          Container(
            width: AppSizes.touchTarget,
            height: AppSizes.touchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(AppSizes.radiusOtpBox),
            ),
            child: Text(
              user?.initials ?? 'SB',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greetingFor(DateTime.now()), style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  user?.name ?? 'Welcome',
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SquareIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            badge: true,
            onPressed: () {},
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
      final limit = controller.user.value?.creditLimit ?? 0;

      return HeroCard(
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your pre-approved limit',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryMuted,
                  ),
                ),
                if (limit > 0)
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
            Text(
              limit > 0 ? Formatters.rupees(limit) : '—',
              style: AppTextStyles.amountHero,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              limit > 0
                  ? 'Take any amount from ₹5,000 · Repay in 7–40 days'
                  : 'Finish your profile to see your limit',
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
                onPressed: () => Get.toNamed(RouteNames.applyAmount),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get money now',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontBody,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: AppSizes.s),
                    Icon(Icons.arrow_forward_rounded, size: 18),
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
                const Text('Finish your profile',
                    style: AppTextStyles.sectionTitle),
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
                        color: i < done
                            ? AppColors.primary
                            : AppColors.borderSoft,
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusField),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        onTap: () => Get.toNamed(RouteNames.kyc),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.m),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next: Aadhaar e-KYC',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontBody,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Paperless, via DigiLocker',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four circular shortcuts: calculator, repay, history, support.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusCardSmall),
        onTap: route == null ? null : () => Get.toNamed(route!),
        child: Column(
          children: [
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusCardSmall),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: (index) {
            controller.tabIndex.value = index;
            switch (index) {
              case 2:
                Get.toNamed(RouteNames.repay);
              case 3:
                Get.toNamed(RouteNames.profile);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Loans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.replay_rounded),
              label: 'Repay',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
