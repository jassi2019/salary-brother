import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Not lazyPut: nothing on the splash screen reads this controller, so a
    // lazy one would never be constructed and onReady would never fire —
    // leaving the app stuck on the splash screen forever.
    Get.put<SplashController>(SplashController());
  }
}
