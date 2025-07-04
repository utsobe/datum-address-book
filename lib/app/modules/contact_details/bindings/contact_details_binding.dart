import 'package:get/get.dart';

import '../../../data/models/contact_model.dart';
import '../controllers/contact_details_controller.dart';

class ContactDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactDetailsController>(
      () => ContactDetailsController(Get.arguments as Contact),
    );
  }
}
