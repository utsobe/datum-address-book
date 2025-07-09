import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/address_book/bindings/address_book_binding.dart';
import '../modules/address_book/views/address_book_view.dart';
import '../modules/contact_form/bindings/contact_form_binding.dart';
import '../modules/contact_form/views/contact_form_view.dart';
import '../modules/contact_details/bindings/contact_details_binding.dart';
import '../modules/contact_details/views/contact_details_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
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
        // Contact argument will be passed to the controller via binding
        return const ContactDetailsView();
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
