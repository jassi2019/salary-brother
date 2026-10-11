import 'package:get/get.dart';

import '../routes/route_names.dart';
import '../services/journey_service.dart';
import '../services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (!StorageService.isLoggedIn) {
      Get.offAllNamed(
        StorageService.hasSeenOnboarding
            ? RouteNames.login
            : RouteNames.welcome,
      );
      return;
    }

    // Resume wherever the CRM last said the customer had got to.
    JourneyService.resume();
  }
}
