import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/bindings/auth_binding.dart';
import 'package:salary_brother/routes/app_pages.dart';
import 'package:salary_brother/routes/route_names.dart';
import 'package:salary_brother/views/login_view.dart';
import 'package:salary_brother/views/welcome_view.dart';

/// Wraps a screen in the minimum GetX app it needs to build.
Widget _host(Widget child) =>
    GetMaterialApp(home: child, getPages: AppPages.routes);

/// Sets the logical screen size for one test, in device-independent pixels.
void _screen(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(Get.reset);

  group('WelcomeView', () {
    testWidgets('the headline is not covered by the floating cards',
        (tester) async {
      // Regression: the cards were Positioned at fixed offsets while the
      // headline was pinned to the bottom of the hero, so on a short screen
      // they slid over the text.
      _screen(tester);

      await tester.pumpWidget(_host(const WelcomeView()));
      await tester.pumpAndSettle();

      final headline = tester.getRect(
        find.text('Your salary, a little early.'),
      );
      final receipt = tester.getRect(find.text('Credited to your bank'));
      final chip = tester.getRect(find.text('Salary day'));

      expect(
        headline.top,
        greaterThanOrEqualTo(receipt.bottom),
        reason: 'the receipt card overlaps the headline',
      );
      expect(
        headline.top,
        greaterThanOrEqualTo(chip.bottom),
        reason: 'the salary-day chip overlaps the headline',
      );
    });

    testWidgets('survives a short screen without overflowing',
        (tester) async {
      // A short phone — the size that used to push the headline under the
      // cards.
      _screen(tester, height: 640);

      await tester.pumpWidget(_host(const WelcomeView()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('LoginView', () {
    testWidgets('lays out with the keyboard up', (tester) async {
      // Regression: without a scroll view the Column's Spacer collapsed and
      // the field's text was laid out off-screen — the digits only appeared
      // once the keyboard was dismissed.
      AuthBinding().dependencies();

      _screen(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);

      await tester.pumpWidget(_host(const LoginView()));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'the login screen overflows when the keyboard is open',
      );
    });

    testWidgets('typed digits are on screen while the keyboard is up',
        (tester) async {
      AuthBinding().dependencies();

      _screen(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);

      await tester.pumpWidget(_host(const LoginView()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byType(TextField));
      expect(
        field.bottom,
        lessThanOrEqualTo(844 - 320),
        reason: 'the field is laid out under the keyboard',
      );
    });

    testWidgets('Need help? opens support', (tester) async {
      AuthBinding().dependencies();

      _screen(tester);

      await tester.pumpWidget(_host(const LoginView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Need help?'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, RouteNames.support);
    });
  });

  group('no inert controls', () {
    testWidgets('every enabled button on login does something',
        (tester) async {
      AuthBinding().dependencies();

      _screen(tester);

      await tester.pumpWidget(_host(const LoginView()));
      await tester.pumpAndSettle();

      // An enabled button whose callback does nothing reads as a broken app.
      for (final button in tester.widgetList<TextButton>(
        find.byType(TextButton),
      )) {
        expect(
          button.onPressed,
          isNotNull,
          reason: 'a TextButton on the login screen has no callback',
        );
      }
    });
  });
}
