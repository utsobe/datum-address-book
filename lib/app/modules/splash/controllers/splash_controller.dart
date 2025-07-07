import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/themes/theme_service.dart';
import '../../../core/language/localization_service.dart';

class SplashController extends GetxController {
  final loadingStatus = 'Initializing...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize StorageService
      loadingStatus.value = 'Loading storage...';
      await Get.putAsync(() async {
        final storageService = StorageService();
        await storageService.onInit();
        return storageService;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize ThemeService
      loadingStatus.value = 'Setting up themes...';
      await Get.putAsync(() async {
        final themeService = ThemeService();
        await themeService.onInit();
        return themeService;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize LocalizationService
      loadingStatus.value = 'Loading languages...';
      await Get.putAsync(() async {
        final localizationService = LocalizationService();
        await localizationService.onInit();
        return localizationService;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Final setup
      loadingStatus.value = 'Finalizing setup...';
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to main app
      Get.offNamed('/address-book');
    } catch (e) {
      loadingStatus.value = 'Error: ${e.toString()}';
      // Retry after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      _initializeApp();
    }
  }
}
