import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/dashboard_controller.dart';
import '../routes/route_names.dart';
import '../services/journey_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/brand_config.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/avatar.dart';
import '../widgets/square_icon_button.dart';

/// Screen 09 — the customer's own details, the legal links, and logout.
class ProfileView extends GetView<DashboardController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSizes.screenPadding),
          child: SquareIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Back',
            onPressed: Get.back<void>,
          ),
        ),
        leadingWidth: 64,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            _identity(),
            const SizedBox(height: 18),
            _details(),
            const SizedBox(height: 18),
            _legal(),
            const SizedBox(height: 18),
            _logout(),
            const SizedBox(height: AppSizes.xl),
            const Text(
              '${BrandConfig.companyName}\n'
              'RBI Reg. No. ${BrandConfig.rbiRegistrationNumber}',
              textAlign: TextAlign.center,
              style: AppTextStyles.legal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _identity() {
    return Obx(() {
      final user = controller.user.value;

      return Row(
        children: [
          Avatar(user: user, size: 56, fontSize: 18),
          const SizedBox(width: AppSizes.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Your profile',
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+91 ${Formatters.mobile(StorageService.mobile ?? '')}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _details() {
    return Obx(() {
      final user = controller.user.value;
      final rows = <(String, String?)>[
        ('Email', user?.email),
        ('PAN', StorageService.pancard),
        ('Employer', user?.employerName),
        (
          'Monthly income',
          user?.monthlyIncome == null
              ? null
              : Formatters.rupees(user!.monthlyIncome!),
        ),
      ].where((r) => (r.$2 ?? '').isNotEmpty).toList();

      if (rows.isEmpty) return const SizedBox.shrink();

      return AppCard(
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: Text(rows[i].$1, style: AppTextStyles.caption),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Text(rows[i].$2!, style: AppTextStyles.bodyBold),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _legal() {
    final links = <(IconData, String, String)>[
      (Icons.shield_outlined, 'Privacy policy', BrandConfig.privacyPolicyUrl),
      (Icons.description_outlined, 'Terms and conditions', BrandConfig.termsUrl),
      (Icons.gavel_rounded, 'Grievance redressal', BrandConfig.grievanceUrl),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < links.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _tile(
              icon: links[i].$1,
              label: links[i].$2,
              onTap: () => _open(links[i].$3),
            ),
          ],
          const Divider(height: 1),
          _tile(
            icon: Icons.headset_mic_outlined,
            label: 'Support',
            onTap: () => Get.toNamed(RouteNames.support),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSizes.m),
            Expanded(child: Text(label, style: AppTextStyles.bodyBold)),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logout() {
    return OutlinedButton(
      onPressed: _confirmLogout,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: const Text('Log out'),
    );
  }

  /// Logging out clears the session, so it asks first.
  Future<void> _confirmLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Log out?', style: AppTextStyles.h3),
        content: const Text(
          'You will need your mobile number and an OTP to sign back in.',
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await JourneyService.logout();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        '',
        'Could not open that page',
        titleText: const SizedBox.shrink(),
      );
    }
  }
}
