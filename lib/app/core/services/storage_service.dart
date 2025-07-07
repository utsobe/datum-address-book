import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/contact_model.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late Box<Contact> _contactsBox;
  late Box _settingsBox;

  Box<Contact> get contactsBox => _contactsBox;
  Box get settingsBox => _settingsBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    print('StorageService.onInit() starting...');
    await _initializeHive();
    print('StorageService.onInit() completed');
  }

  Future<void> _initializeHive() async {
    try {
      // Get application documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      print('App documents directory: ${appDocumentDir.path}');

      // Initialize Hive with the path
      Hive.init(appDocumentDir.path);

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ContactAdapter());
        print('Contact adapter registered');
      }

      // Open boxes
      _contactsBox = await Hive.openBox<Contact>('contacts');
      _settingsBox = await Hive.openBox('settings');

      print('Hive boxes opened successfully');
      print('Contacts box has ${_contactsBox.length} items');
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  // Contact operations
  Future<void> saveContact(Contact contact) async {
    await _contactsBox.put(contact.id, contact);
  }

  Future<void> deleteContact(String id) async {
    await _contactsBox.delete(id);
  }

  Contact? getContact(String id) {
    return _contactsBox.get(id);
  }

  List<Contact> getAllContacts() {
    try {
      final contacts = _contactsBox.values.toList();
      print(
        'StorageService.getAllContacts() returning ${contacts.length} contacts',
      );
      return contacts;
    } catch (e) {
      print('Error in getAllContacts: $e');
      return [];
    }
  }

  List<Contact> getFavoriteContacts() {
    return _contactsBox.values.where((contact) => contact.isFavorite).toList();
  }

  Future<void> clearAllContacts() async {
    await _contactsBox.clear();
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  Future<void> clearAllSettings() async {
    await _settingsBox.clear();
  }

  // Search contacts
  List<Contact> searchContacts(String query) {
    if (query.isEmpty) return getAllContacts();

    final lowercaseQuery = query.toLowerCase();
    return _contactsBox.values.where((contact) {
      return contact.firstName.toLowerCase().contains(lowercaseQuery) ||
          contact.lastName.toLowerCase().contains(lowercaseQuery) ||
          contact.displayName.toLowerCase().contains(lowercaseQuery) ||
          (contact.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (contact.phone?.contains(query) ?? false) ||
          (contact.company?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Export/Import operations
  List<Map<String, dynamic>> exportContacts() {
    return _contactsBox.values.map((contact) => contact.toJson()).toList();
  }

  Future<void> importContacts(List<Map<String, dynamic>> contactsJson) async {
    for (final contactJson in contactsJson) {
      final contact = Contact.fromJson(contactJson);
      await saveContact(contact);
    }
  }

  // Statistics
  int get totalContacts => _contactsBox.length;
  int get totalFavorites => getFavoriteContacts().length;

  @override
  void onClose() {
    _contactsBox.close();
    _settingsBox.close();
    super.onClose();
  }
}
