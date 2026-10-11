import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/bindings/auth_binding.dart';
import 'package:salary_brother/bindings/splash_binding.dart';
import 'package:salary_brother/controllers/auth_controller.dart';
import 'package:salary_brother/controllers/splash_controller.dart';

void main() {
  tearDown(Get.reset);

  group('SplashBinding', () {
    test('constructs the controller eagerly', () {
      // Regression: with lazyPut the controller was only built on first use,
      // and nothing on the splash screen reads it — so onReady never fired
      // and the app sat on the splash screen forever.
      SplashBinding().dependencies();

      expect(
        Get.isRegistered<SplashController>(),
        isTrue,
        reason: 'the binding did not register SplashController',
      );
      expect(
        Get.isPrepared<SplashController>(),
        isFalse,
        reason: 'SplashController must not be lazy — it would never '
            'be constructed, and the splash screen would never advance',
      );
    });
  });

  group('AuthBinding', () {
    test('registers the controller', () {
      AuthBinding().dependencies();

      expect(Get.isRegistered<AuthController>(), isTrue);
    });

    test('running twice keeps the same controller', () {
      // Both the login and OTP routes carry this binding. A second Get.put
      // would swap in a fresh controller and lose the mobile number and
      // profile id that the OTP screen needs to verify.
      AuthBinding().dependencies();
      final first = Get.find<AuthController>();
      first.mobileController.text = '9876543210';
      first.profileId.value = 'abc-123';

      AuthBinding().dependencies();
      final second = Get.find<AuthController>();

      expect(identical(first, second), isTrue);
      expect(second.mobile, '9876543210');
      expect(second.profileId.value, 'abc-123');
    });
  });
}
