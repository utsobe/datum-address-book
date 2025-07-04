import 'package:get/get.dart';

import '../controllers/address_book_controller.dart';

class AddressBookBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressBookController>(
      () => AddressBookController(),
    );
  }
}
