import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/localization_service.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = StorageService.to;
  final LocalizationService _localizationService = LocalizationService.to;

  final currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved language preference
    currentLanguage.value =
        _storageService.getSetting('language', defaultValue: 'en') ?? 'en';
  }

  String get currentLanguageName {
    switch (currentLanguage.value) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    await _storageService.saveSetting('language', languageCode);
    await _localizationService.loadLanguage(languageCode);

    // Update the app locale
    Get.updateLocale(Locale(languageCode));

    Get.snackbar(
      'Language Changed',
      'Language has been changed to $currentLanguageName',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  int get totalContacts => _storageService.totalContacts;
  int get totalFavorites => _storageService.totalFavorites;
}
