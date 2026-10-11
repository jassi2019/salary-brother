import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../utils/brand_config.dart';
import '../widgets/app_card.dart';
import '../widgets/square_icon_button.dart';

/// Contact channels. Falls back to [BrandConfig] when the CRM has not
/// overridden a number, as the reference app does.
class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
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
            const Text('Get in touch', style: AppTextStyles.h2),
            const SizedBox(height: 10),
            const Text(
              'Our team answers every query. Reach us however suits you.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSizes.xxl),
            if (BrandConfig.hasPhone)
              _ContactTile(
                icon: Icons.call_outlined,
                title: 'Call us',
                value: BrandConfig.phone,
                note: BrandConfig.supportHours,
                onTap: () => _launch(Uri(
                  scheme: 'tel',
                  path: BrandConfig.phone,
                )),
              ),
            if (BrandConfig.hasWhatsapp)
              _ContactTile(
                icon: Icons.chat_outlined,
                title: 'WhatsApp us',
                value: BrandConfig.whatsapp,
                onTap: () => _launch(
                  Uri.parse(
                    'https://api.whatsapp.com/send'
                    '?phone=${BrandConfig.whatsapp}&text=Hi',
                  ),
                  external: true,
                ),
              ),
            if (BrandConfig.hasEmail)
              _ContactTile(
                icon: Icons.mail_outline_rounded,
                title: 'Email us',
                value: BrandConfig.email,
                onTap: () => _launch(Uri(
                  scheme: 'mailto',
                  path: BrandConfig.email,
                )),
              ),
            const SizedBox(height: AppSizes.s),
            _officeCard(),
          ],
        ),
      ),
    );
  }

  Widget _officeCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.iconBadge,
                height: AppSizes.iconBadge,
                decoration: BoxDecoration(
                  color: AppColors.tintSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              const Text('Corporate office',
                  style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          const Text(
            BrandConfig.companyAddress,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSizes.m),
          TextButton(
            onPressed: () =>
                _launch(Uri.parse(BrandConfig.mapsUrl), external: true),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri, {bool external = false}) async {
    final mode = external
        ? LaunchMode.externalApplication
        : LaunchMode.platformDefault;

    if (!await launchUrl(uri, mode: mode)) {
      Get.snackbar(
        '',
        'Could not open ${uri.scheme == 'tel' ? 'the dialer' : 'that app'}',
        titleText: const SizedBox.shrink(),
      );
    }
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.note,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.m),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderSoft),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.l),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.tintSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 22, color: AppColors.primary),
                ),
                const SizedBox(width: AppSizes.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.label),
                      const SizedBox(height: 2),
                      Text(value, style: AppTextStyles.bodyBold),
                      if (note != null) ...[
                        const SizedBox(height: 4),
                        Text(note!, style: AppTextStyles.small),
                      ],
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
      ),
    );
  }
}
