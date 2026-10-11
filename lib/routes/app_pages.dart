import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/loan_binding.dart';
import '../bindings/splash_binding.dart';
import '../views/apply_amount_view.dart';
import '../views/dashboard_view.dart';
import '../views/login_view.dart';
import '../views/otp_view.dart';
import '../views/splash_view.dart';
import '../views/welcome_view.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static const String initial = RouteNames.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: RouteNames.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: RouteNames.welcome,
      page: () => const WelcomeView(),
    ),
    GetPage(
      name: RouteNames.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: RouteNames.otp,
      page: () => const OtpView(),
    ),
    GetPage(
      name: RouteNames.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: RouteNames.applyAmount,
      page: () => const ApplyAmountView(),
      binding: LoanBinding(),
    ),
  ];
}
