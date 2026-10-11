import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Shared between the login and OTP screens, so keep it alive across both.
    Get.put<AuthController>(AuthController(), permanent: false);
  }
}
