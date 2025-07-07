import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/language/localization_service.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = StorageService.to;
  final LocalizationService _localizationService = LocalizationService.to;

  final currentLanguage = 'en'.obs;
  final totalContacts = 0.obs;
  final totalFavorites = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved language preference
    currentLanguage.value =
        _storageService.getSetting('language', defaultValue: 'en') ?? 'en';

    // Load initial statistics
    loadStatistics();
  }

  void loadStatistics() {
    totalContacts.value = _storageService.totalContacts;
    totalFavorites.value = _storageService.totalFavorites;
  }

  // Call this method when contacts are updated
  void refreshStatistics() {
    loadStatistics();
  }

  String get currentLanguageName {
    switch (currentLanguage.value) {
      case 'en':
        return 'English';
      case 'ms':
        return 'Bahasa Melayu';
      case 'zh':
        return '中文';
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
      _localizationService.translate('language_changed'),
      '${_localizationService.translate('language_changed_to')} $currentLanguageName',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
