import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../themes/app_themes.dart';

enum AppThemeMode { light, dark, system }

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _themeMode = AppThemeMode.system.obs;
  late Box _box;

  AppThemeMode get themeMode => _themeMode.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    _box = await Hive.openBox('theme_settings');
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = _box.get('theme_mode', defaultValue: 'system');
    switch (savedTheme) {
      case 'light':
        _themeMode.value = AppThemeMode.light;
        break;
      case 'dark':
        _themeMode.value = AppThemeMode.dark;
        break;
      default:
        _themeMode.value = AppThemeMode.system;
    }
    _updateTheme();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode.value = mode;
    await _box.put('theme_mode', mode.toString().split('.').last);
    _updateTheme();
  }

  void _updateTheme() {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        Get.changeTheme(AppThemes.lightTheme);
        break;
      case AppThemeMode.dark:
        Get.changeTheme(AppThemes.darkTheme);
        break;
      case AppThemeMode.system:
        Get.changeTheme(
          Get.isPlatformDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
        );
        break;
    }
  }

  bool get isDarkMode {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return Get.isPlatformDarkMode;
    }
  }

  void toggleTheme() {
    if (_themeMode.value == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else {
      setThemeMode(AppThemeMode.light);
    }
  }
}
