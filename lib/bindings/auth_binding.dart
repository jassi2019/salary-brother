import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Both the login and OTP routes carry this binding, so it runs twice on
    // the way through. Reuse the existing controller: a second Get.put would
    // replace it and lose the mobile number and profile id the OTP screen
    // needs.
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }
  }
}
