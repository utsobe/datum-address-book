import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../data/models/contact_model.dart';
import '../../address_book/controllers/address_book_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class ContactDetailsController extends GetxController {
  final StorageService _storageService = StorageService.to;
  final LocalizationService _localizationService = LocalizationService.to;

  final contact = Rx<Contact>(Contact(firstName: '', lastName: ''));

  ContactDetailsController(Contact initialContact) {
    contact.value = initialContact;
  }

  Future<void> toggleFavorite() async {
    try {
      final updatedContact = contact.value.copyWith(
        isFavorite: !contact.value.isFavorite,
        updatedAt: DateTime.now(),
      );

      await _storageService.saveContact(updatedContact);
      contact.value = updatedContact;

      // Refresh the address book
      final addressBookController = Get.find<AddressBookController>();
      await addressBookController.loadContacts();

      // Refresh settings statistics if controller exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.refreshStatistics();
      } catch (e) {
        // SettingsController not found, ignore
      }

      Get.snackbar(
        'Success',
        contact.value.isFavorite
            ? 'Added to favorites'
            : 'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteContact() async {
    try {
      await _storageService.deleteContact(contact.value.id);

      // Refresh the address book
      final addressBookController = Get.find<AddressBookController>();
      await addressBookController.loadContacts();

      // Refresh settings statistics if controller exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.refreshStatistics();
      } catch (e) {
        // SettingsController not found, ignore
      }

      Get.snackbar(
        'Success',
        _localizationService.contactDeleted,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete contact',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
