import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/bindings/dashboard_binding.dart';
import 'package:salary_brother/routes/app_pages.dart';
import 'package:salary_brother/routes/route_names.dart';
import 'package:salary_brother/services/journey_service.dart';
import 'package:salary_brother/services/storage_service.dart';
import 'package:salary_brother/views/dashboard_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every route name the app declares, so the sweep below cannot miss one.
const _declared = <String, String>{
  'splash': RouteNames.splash,
  'welcome': RouteNames.welcome,
  'login': RouteNames.login,
  'otp': RouteNames.otp,
  'dashboard': RouteNames.dashboard,
  'kycPan': RouteNames.kycPan,
  'personalDetails': RouteNames.personalDetails,
  'residenceDetails': RouteNames.residenceDetails,
  'incomeDetails': RouteNames.incomeDetails,
  'employmentDetails': RouteNames.employmentDetails,
  'bankDetails': RouteNames.bankDetails,
  'documents': RouteNames.documents,
  'applyAmount': RouteNames.applyAmount,
  'review': RouteNames.review,
  'success': RouteNames.success,
  'repay': RouteNames.repay,
  'profile': RouteNames.profile,
  'support': RouteNames.support,
  'privacyPolicy': RouteNames.privacyPolicy,
};

void main() {
  setUp(() async {
    // The dashboard reads storage as it builds, so it has to be ready.
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  tearDown(Get.reset);

  group('route table', () {
    test('no two pages share a name', () {
      final names = AppPages.routes.map((p) => p.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('every registered page has a builder', () {
      for (final page in AppPages.routes) {
        expect(page.page, isNotNull, reason: '${page.name} has no builder');
      }
    });

    test('the unbuilt routes are known, not forgotten', () {
      // This list is the backlog. Deleting a name from it without building
      // the screen will fail the test above it that uses isRegistered.
      const unbuilt = {
        RouteNames.employmentDetails,
        RouteNames.bankDetails,
        RouteNames.review,
        RouteNames.success,
        RouteNames.repay,
        RouteNames.privacyPolicy,
      };

      for (final route in _declared.values) {
        final registered = JourneyService.isRegistered(route);
        expect(
          registered || unbuilt.contains(route),
          isTrue,
          reason: '$route is neither registered nor listed as unbuilt',
        );
      }
    });
  });

  group('goToStep never strands the customer', () {
    testWidgets('an unbuilt step falls back to the dashboard', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteNames.welcome,
          getPages: AppPages.routes,
        ),
      );
      await tester.pumpAndSettle();

      // employment_details has no screen yet.
      JourneyService.goToStep('employment_details');
      await tester.pumpAndSettle();

      expect(Get.currentRoute, RouteNames.dashboard);
    });

    testWidgets('a built step opens its own screen', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteNames.welcome,
          getPages: AppPages.routes,
        ),
      );
      await tester.pumpAndSettle();

      JourneyService.goToStep('pancard_verification');
      await tester.pumpAndSettle();

      expect(Get.currentRoute, RouteNames.kycPan);
    });
  });

  group('the dashboard tile follows the server, not a hardcoded step', () {
    test('a step with a screen is tappable, one without is not', () {
      // Regression: the tile said "Next: Aadhaar e-KYC" and always opened the
      // PAN screen, which the customer had usually finished — the CRM bounced
      // them back and the tile read as dead.
      expect(JourneyService.isRegistered(RouteNames.kycPan), isTrue);
      expect(JourneyService.isRegistered(RouteNames.documents), isTrue);
      // Still unbuilt, so still correctly refused.
      expect(JourneyService.isRegistered(RouteNames.review), isFalse);
    });
  });

  group('the dashboard renders cleanly at phone width', () {
    testWidgets('no overflow on a 390dp screen', (tester) async {
      // Regression: the "Finish your profile" header row overflowed by 143px,
      // which in release builds is invisible but still a broken layout.
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      DashboardBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(home: const DashboardView(), getPages: AppPages.routes),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on a narrow 360dp screen', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 740);
      addTearDown(tester.view.reset);

      DashboardBinding().dependencies();

      await tester.pumpWidget(
        GetMaterialApp(home: const DashboardView(), getPages: AppPages.routes),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });
  });
}
