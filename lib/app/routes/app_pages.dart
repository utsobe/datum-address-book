import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/contact_model.dart';
import '../modules/address_book/bindings/address_book_binding.dart';
import '../modules/address_book/views/address_book_view.dart';
import '../modules/contact_form/bindings/contact_form_binding.dart';
import '../modules/contact_form/views/contact_form_view.dart';
import '../modules/contact_details/bindings/contact_details_binding.dart';
import '../modules/contact_details/views/contact_details_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.addressBook;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.addressBook,
      page: () => const AddressBookView(),
      binding: AddressBookBinding(),
    ),
    GetPage(
      name: _Paths.contactForm,
      page: () => const ContactFormView(),
      binding: ContactFormBinding(),
    ),
    GetPage(
      name: _Paths.contactDetails,
      page: () {
        final contact = Get.arguments;
        print('ContactDetailsView route received argument: $contact');
        if (contact is Contact) {
          return ContactDetailsView(contact: contact);
        } else {
          print('ERROR: Invalid contact argument in route: $contact');
          // Navigate back if invalid argument
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
            Get.snackbar(
              'Error',
              'Invalid contact data',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
      binding: ContactDetailsBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
