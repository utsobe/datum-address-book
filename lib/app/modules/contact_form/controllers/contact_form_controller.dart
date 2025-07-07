import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/language/localization_service.dart';
import '../../../data/models/contact_model.dart';
import '../../address_book/controllers/address_book_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class ContactFormController extends GetxController {
  final StorageService _storageService = StorageService.to;
  final LocalizationService _localizationService = LocalizationService.to;

  // Form key and controllers
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final workPhoneController = TextEditingController();
  final workEmailController = TextEditingController();
  final companyController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isEditing = false.obs;
  final avatarPath = ''.obs;

  Contact? _editingContact;

  @override
  void onInit() {
    super.onInit();

    // Check if we're editing an existing contact
    final contact = Get.arguments as Contact?;
    if (contact != null) {
      _editingContact = contact;
      isEditing.value = true;
      _loadContactData(contact);
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    workPhoneController.dispose();
    workEmailController.dispose();
    companyController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _loadContactData(Contact contact) {
    firstNameController.text = contact.firstName;
    lastNameController.text = contact.lastName;
    phoneController.text = contact.phone ?? '';
    emailController.text = contact.email ?? '';
    workPhoneController.text = contact.workPhone ?? '';
    workEmailController.text = contact.workEmail ?? '';
    companyController.text = contact.company ?? '';
    addressController.text = contact.address ?? '';
    notesController.text = contact.notes ?? '';
    avatarPath.value = contact.avatarPath ?? '';
  }

  void setAvatarPath(String path) {
    avatarPath.value = path;
  }

  void removeAvatar() {
    avatarPath.value = '';
  }

  Future<void> saveContact() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final contact =
          _editingContact?.copyWith(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            phone: phoneController.text.trim(), // Required field
            email: emailController.text.trim(), // Required field
            workPhone: workPhoneController.text.trim().isEmpty
                ? null
                : workPhoneController.text.trim(),
            workEmail: workEmailController.text.trim().isEmpty
                ? null
                : workEmailController.text.trim(),
            company: companyController.text.trim().isEmpty
                ? null
                : companyController.text.trim(),
            address: addressController.text.trim(), // Required field
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            avatarPath: avatarPath.value.isEmpty ? null : avatarPath.value,
            updatedAt: DateTime.now(),
          ) ??
          Contact(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            phone: phoneController.text.trim(), // Required field
            email: emailController.text.trim(), // Required field
            workPhone: workPhoneController.text.trim().isEmpty
                ? null
                : workPhoneController.text.trim(),
            workEmail: workEmailController.text.trim().isEmpty
                ? null
                : workEmailController.text.trim(),
            company: companyController.text.trim().isEmpty
                ? null
                : companyController.text.trim(),
            address: addressController.text.trim(), // Required field
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            avatarPath: avatarPath.value.isEmpty ? null : avatarPath.value,
          );

      await _storageService.saveContact(contact);

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
        isEditing.value
            ? _localizationService.contactUpdated
            : _localizationService.contactSaved,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
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

  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      final addressBookController = Get.find<AddressBookController>();
      final imagePath = await addressBookController.pickImage(
        fromCamera: fromCamera,
      );
      if (imagePath != null) {
        setAvatarPath(imagePath);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
