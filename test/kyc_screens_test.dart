import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/bindings/kyc_binding.dart';
import 'package:salary_brother/controllers/kyc_controller.dart';
import 'package:salary_brother/controllers/profile_controller.dart';
import 'package:salary_brother/routes/app_pages.dart';
import 'package:salary_brother/routes/route_names.dart';
import 'package:salary_brother/services/api/api_events.dart';
import 'package:salary_brother/services/journey_service.dart';
import 'package:salary_brother/views/income_details_view.dart';
import 'package:salary_brother/views/kyc_pan_view.dart';
import 'package:salary_brother/views/personal_details_view.dart';
import 'package:salary_brother/views/residence_details_view.dart';

Widget _host(Widget child) =>
    GetMaterialApp(home: child, getPages: AppPages.routes);

void _screen(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(Get.reset);

  group('the steps after OTP are reachable', () {
    test('each has a registered route', () {
      // Before these screens existed, the CRM's next_step pointed at routes
      // GetX could not resolve and the journey stalled on the OTP screen.
      const steps = [
        ApiEvents.pancard,
        ApiEvents.personalDetails,
        ApiEvents.residenceDetails,
        ApiEvents.incomeDetails,
      ];

      for (final step in steps) {
        final route = JourneyService.routeFor(step);
        expect(route, isNotNull, reason: '$step has no route');
        expect(
          JourneyService.isRegistered(route!),
          isTrue,
          reason: '$step maps to $route, which has no page',
        );
      }
    });
  });

  group('KycPanView', () {
    testWidgets('builds and gates Continue on a valid PAN and income',
        (tester) async {
      _screen(tester);
      KycBinding().dependencies();
      final controller = Get.find<KycController>();

      await tester.pumpWidget(_host(const KycPanView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.canSubmit, isFalse);

      controller.panController.text = 'ABCDE1234F';
      controller.incomeController.text = '40000';
      expect(controller.canSubmit, isTrue);
    });

    testWidgets('a malformed PAN keeps Continue disabled', (tester) async {
      _screen(tester);
      KycBinding().dependencies();
      final controller = Get.find<KycController>();

      await tester.pumpWidget(_host(const KycPanView()));
      await tester.pumpAndSettle();

      controller.panController.text = 'ABCD1234F';
      controller.incomeController.text = '40000';
      expect(controller.canSubmit, isFalse);
    });
  });

  group('PersonalDetailsView', () {
    testWidgets('builds', (tester) async {
      _screen(tester);
      ProfileBinding().dependencies();

      await tester.pumpWidget(_host(const PersonalDetailsView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('spouse fields appear only once married is chosen',
        (tester) async {
      _screen(tester);
      ProfileBinding().dependencies();
      final controller = Get.find<ProfileController>();

      await tester.pumpWidget(_host(const PersonalDetailsView()));
      await tester.pumpAndSettle();

      expect(find.text("Spouse's name"), findsNothing);

      controller.maritalStatus.value = '2';
      await tester.pumpAndSettle();

      expect(find.text("Spouse's name"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfileController validation', () {
    late ProfileController controller;

    setUp(() {
      ProfileBinding().dependencies();
      controller = Get.find<ProfileController>();
    });

    test('personal needs every field, and spouse fields when married', () {
      expect(controller.canSubmitPersonal, isFalse);

      controller.nameController.text = 'Rahul Kumar';
      controller.emailController.text = 'rahul@example.com';
      controller.dobController.text = '1995-04-12';
      controller.gender.value = '1';
      controller.maritalStatus.value = '1';
      expect(controller.canSubmitPersonal, isTrue);

      // Switching to married reopens two more required fields.
      controller.maritalStatus.value = '2';
      expect(controller.canSubmitPersonal, isFalse);

      controller.spouseNameController.text = 'Priya Kumar';
      controller.spouseMobileController.text = '9876543210';
      expect(controller.canSubmitPersonal, isTrue);
    });

    test('residence needs an address, a PIN code and a type', () {
      expect(controller.canSubmitResidence, isFalse);

      controller.addressLine1Controller.text = 'C2/13, Second Floor';
      controller.pincodeController.text = '110088';
      controller.residenceType.value = '2';
      expect(controller.canSubmitResidence, isTrue);

      // A five-digit PIN is not a PIN.
      controller.pincodeController.text = '11008';
      expect(controller.canSubmitResidence, isFalse);
    });

    test('income needs an amount, a type, a mode and a salary day', () {
      expect(controller.canSubmitIncome, isFalse);

      controller.monthlyIncomeController.text = '40000';
      controller.incomeType.value = '1';
      controller.salaryMode.value = '1';
      controller.salaryDay.value = '1';
      expect(controller.canSubmitIncome, isTrue);
    });

    test('income strips formatting before sending', () {
      controller.monthlyIncomeController.text = '₹40,000';
      expect(controller.income, '40000');
    });

    test('the CRM dropdown values are the ones it expects', () {
      // These ids travel on the wire; renaming a label is safe, renaming a
      // key is not.
      expect(ProfileController.genders.keys, ['1', '2']);
      expect(ProfileController.maritalStatuses['2'], 'Married');
      expect(ProfileController.residenceTypes.keys, ['1', '2', '3']);
      expect(ProfileController.incomeTypes.keys, ['1', '2']);
      expect(ProfileController.salaryModes.keys, ['1', '2', '3']);
    });
  });

  group('the remaining screens build', () {
    testWidgets('residence', (tester) async {
      _screen(tester);
      ProfileBinding().dependencies();

      await tester.pumpWidget(_host(const ResidenceDetailsView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('income', (tester) async {
      _screen(tester);
      ProfileBinding().dependencies();

      await tester.pumpWidget(_host(const IncomeDetailsView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('all four survive a short screen', (tester) async {
      _screen(tester, height: 640);
      KycBinding().dependencies();
      ProfileBinding().dependencies();

      for (final screen in [
        const KycPanView(),
        const PersonalDetailsView(),
        const ResidenceDetailsView(),
        const IncomeDetailsView(),
      ]) {
        await tester.pumpWidget(_host(screen));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} overflows on a short screen',
        );
      }
    });

    testWidgets('Help opens support', (tester) async {
      _screen(tester);
      KycBinding().dependencies();

      await tester.pumpWidget(_host(const KycPanView()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, RouteNames.support);
    });
  });
}
