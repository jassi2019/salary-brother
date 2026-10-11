import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/bindings/splash_binding.dart';
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
}
