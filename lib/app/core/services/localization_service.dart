import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LocalizationService extends GetxService {
  static const String fallbackLocale = 'en';
  static const List<String> supportedLanguages = ['en', 'fr', 'es'];

  Map<String, String> _localizedStrings = {};

  static LocalizationService get to => Get.find();

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadLanguage(Get.deviceLocale?.languageCode ?? fallbackLocale);
  }

  Future<void> loadLanguage(String languageCode) async {
    // Ensure the language is supported
    if (!supportedLanguages.contains(languageCode)) {
      languageCode = fallbackLocale;
    }

    try {
      String jsonString = await rootBundle.loadString(
        'assets/locales/$languageCode.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (e) {
      // If loading fails, load fallback locale
      if (languageCode != fallbackLocale) {
        await loadLanguage(fallbackLocale);
      }
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String translation = _localizedStrings[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translation;
  }

  // Getters for commonly used strings
  String get appName => translate('app_name');
  String get contacts => translate('contacts');
  String get addContact => translate('add_contact');
  String get editContact => translate('edit_contact');
  String get contactDetails => translate('contact_details');
  String get searchContacts => translate('search_contacts');
  String get noContacts => translate('no_contacts');
  String get name => translate('name');
  String get phone => translate('phone');
  String get email => translate('email');
  String get address => translate('address');
  String get company => translate('company');
  String get notes => translate('notes');
  String get firstName => translate('first_name');
  String get lastName => translate('last_name');
  String get mobile => translate('mobile');
  String get work => translate('work');
  String get home => translate('home');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get call => translate('call');
  String get message => translate('message');
  String get emailAction => translate('email_action');
  String get share => translate('share');
  String get favorite => translate('favorite');
  String get unfavorite => translate('unfavorite');
  String get favorites => translate('favorites');
  String get allContacts => translate('all_contacts');
  String get recent => translate('recent');
  String get confirmDelete => translate('confirm_delete');
  String get deleteContact => translate('delete_contact');
  String get contactSaved => translate('contact_saved');
  String get contactUpdated => translate('contact_updated');
  String get contactDeleted => translate('contact_deleted');
  String get errorSaving => translate('error_saving');
  String get errorLoading => translate('error_loading');
  String get requiredField => translate('required_field');
  String get invalidEmail => translate('invalid_email');
  String get invalidPhone => translate('invalid_phone');
  String get takePhoto => translate('take_photo');
  String get choosePhoto => translate('choose_photo');
  String get removePhoto => translate('remove_photo');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get language => translate('language');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemMode => translate('system_mode');
  String get about => translate('about');
  String get version => translate('version');
  String get developer => translate('developer');
}
