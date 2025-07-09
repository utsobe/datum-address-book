import 'package:get/get.dart';

import '../../../data/models/contact_model.dart';
import '../controllers/contact_details_controller.dart';

class ContactDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ContactDetailsController>(() {
      final contact = Get.arguments;
      print('ContactDetailsBinding received argument: $contact');
      if (contact is Contact) {
        return ContactDetailsController(contact);
      } else {
        print('ERROR: Invalid contact argument: $contact');
        // Return a dummy contact to prevent crash
        return ContactDetailsController(
          Contact(firstName: 'Error', lastName: 'Contact'),
        );
      }
    }());
  }
}
