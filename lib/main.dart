import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'routes/app_pages.dart';
import 'services/storage_service.dart';
import 'utils/app_strings.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  // The splash is plum, so its status bar icons must be light. SplashView
  // restores the dark ones when it hands off to the rest of the app.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const SalaryBrotherApp());
}

class SalaryBrotherApp extends StatelessWidget {
  const SalaryBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) => GetMaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
