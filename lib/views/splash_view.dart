import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import '../widgets/brand_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 110, showWordmark: false, onPlum: true),
            const SizedBox(height: 28),
            const Text(
              'SALARY BROTHER',
              style: TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.tagline,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onPrimaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
