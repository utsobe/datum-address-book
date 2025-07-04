import 'package:get/get.dart';

import '../modules/address_book/bindings/address_book_binding.dart';
import '../modules/address_book/views/address_book_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ADDRESS_BOOK;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ADDRESS_BOOK,
      page: () => const AddressBookView(),
      binding: AddressBookBinding(),
    ),
  ];
}
