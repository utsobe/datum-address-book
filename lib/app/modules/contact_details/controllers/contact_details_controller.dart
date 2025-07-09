import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/language/localization_service.dart';
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

  @override
  void onReady() {
    super.onReady();
    print(
      'ContactDetailsController: onReady called for contact ${contact.value.displayName}',
    );
    print('ContactDetailsController: Avatar path: ${contact.value.avatarPath}');
    // Force update to ensure reactive UI
    contact.refresh();
  }

  /// Update the contact data (useful when returning from edit)
  void updateContact(Contact updatedContact) {
    contact.value = updatedContact;
    print(
      'ContactDetailsController: Updated contact to ${updatedContact.displayName}',
    );
  }

  /// Refresh contact data from storage
  Future<void> refreshContact() async {
    try {
      final refreshedContact = await _storageService.getContact(
        contact.value.id,
      );
      if (refreshedContact != null) {
        contact.value = refreshedContact;
        print(
          'ContactDetailsController: Refreshed contact from storage: ${refreshedContact.displayName}',
        );
      }
    } catch (e) {
      print('Error refreshing contact: $e');
    }
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
