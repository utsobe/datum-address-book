import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/language/localization_service.dart';
import '../../../data/models/contact_model.dart';
import '../../settings/controllers/settings_controller.dart';

class AddressBookController extends GetxController {
  final StorageService _storageService = StorageService.to;
  final LocalizationService _localizationService = LocalizationService.to;

  // Observable variables
  final contacts = <Contact>[].obs;
  final filteredContacts = <Contact>[].obs;
  final favoriteContacts = <Contact>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedTab = 0.obs;

  // Search controller
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Wait a bit to ensure storage service is initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      loadContacts();
    });

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterContacts();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load all contacts from storage
  Future<void> loadContacts() async {
    try {
      isLoading.value = true;

      // Check if storage service is initialized and ready
      if (!Get.isRegistered<StorageService>()) {
        print('StorageService not registered, waiting...');
        await Future.delayed(const Duration(milliseconds: 500));
        return loadContacts(); // Retry
      }

      // Check if storage service is initialized
      if (_storageService.contactsBox.isOpen) {
        final loadedContacts = _storageService.getAllContacts();

        // Sort contacts alphabetically
        loadedContacts.sort((a, b) => a.displayName.compareTo(b.displayName));

        contacts.value = loadedContacts;
        favoriteContacts.value = loadedContacts
            .where((c) => c.isFavorite)
            .toList();
        _filterContacts();

        print('Loaded ${loadedContacts.length} contacts successfully');
      } else {
        // If box is not open, retry after a short delay
        await Future.delayed(const Duration(milliseconds: 200));
        if (_storageService.contactsBox.isOpen) {
          await loadContacts();
        } else {
          throw Exception('Storage service not initialized');
        }
      }
    } catch (e) {
      print('Error loading contacts: $e'); // Debug log
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          _localizationService.errorLoading,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  // Filter contacts based on search query and selected tab
  void _filterContacts() {
    List<Contact> contactsToFilter;

    switch (selectedTab.value) {
      case 1: // Favorites
        contactsToFilter = favoriteContacts;
        break;
      default: // All contacts
        contactsToFilter = contacts;
    }

    if (searchQuery.value.isEmpty) {
      filteredContacts.value = contactsToFilter;
    } else {
      filteredContacts.value = contactsToFilter.where((contact) {
        final query = searchQuery.value.toLowerCase();
        return contact.firstName.toLowerCase().contains(query) ||
            contact.lastName.toLowerCase().contains(query) ||
            contact.displayName.toLowerCase().contains(query) ||
            (contact.email?.toLowerCase().contains(query) ?? false) ||
            (contact.phone?.contains(searchQuery.value) ?? false) ||
            (contact.company?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  // Change tab
  void changeTab(int index) {
    selectedTab.value = index;
    _filterContacts();
  }

  // Save contact
  Future<void> saveContact(Contact contact) async {
    try {
      isLoading.value = true;
      await _storageService.saveContact(contact);
      await loadContacts();

      // Refresh settings statistics if controller exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.refreshStatistics();
      } catch (e) {
        // SettingsController not found, ignore
      }

      Get.snackbar(
        'Success',
        _localizationService.contactSaved,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _localizationService.errorSaving,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update contact
  Future<void> updateContact(Contact contact) async {
    try {
      isLoading.value = true;
      final updatedContact = contact.copyWith(updatedAt: DateTime.now());
      await _storageService.saveContact(updatedContact);
      await loadContacts();

      // Refresh settings statistics if controller exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.refreshStatistics();
      } catch (e) {
        // SettingsController not found, ignore
      }

      Get.snackbar(
        'Success',
        _localizationService.contactUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _localizationService.errorSaving,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete contact
  Future<void> deleteContact(Contact contact) async {
    try {
      await _storageService.deleteContact(contact.id);

      // Delete avatar file if exists
      if (contact.avatarPath != null && contact.avatarPath!.isNotEmpty) {
        final file = File(contact.avatarPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await loadContacts();

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
        'Error deleting contact',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(Contact contact) async {
    final updatedContact = contact.copyWith(
      isFavorite: !contact.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateContact(updatedContact);
  }

  // Pick image for contact avatar using the dedicated service
  Future<String?> pickImage({bool fromCamera = false}) async {
    final imagePickerService = ImagePickerService.to;
    return await imagePickerService.pickImage(fromCamera: fromCamera);
  }

  // Show delete confirmation dialog
  Future<bool> showDeleteConfirmation(Contact contact) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(_localizationService.deleteContact),
        content: Text(_localizationService.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(_localizationService.cancel),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_localizationService.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterContacts();
  }

  // Get contacts count
  int get totalContacts => contacts.length;
  int get totalFavorites => favoriteContacts.length;
  int get filteredCount => filteredContacts.length;
}
