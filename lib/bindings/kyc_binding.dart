import 'package:get/get.dart';

import '../controllers/kyc_controller.dart';
import '../controllers/profile_controller.dart';

/// PAN step.
class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycController>(KycController.new);
  }
}

/// The personal, residence and income steps, which share one controller so a
/// value entered on one is still there if the CRM sends the customer back.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController());
    }
  }
}
