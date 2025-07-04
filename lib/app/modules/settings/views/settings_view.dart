import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/theme_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.to;
    final themeService = ThemeService.to;

    return Scaffold(
      appBar: AppBar(title: Text(localization.settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    localization.theme,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Obx(() {
                    final currentTheme = themeService.themeMode;
                    String themeName;
                    switch (currentTheme) {
                      case AppThemeMode.light:
                        themeName = localization.lightMode;
                        break;
                      case AppThemeMode.dark:
                        themeName = localization.darkMode;
                        break;
                      case AppThemeMode.system:
                        themeName = localization.systemMode;
                        break;
                    }
                    return Text(themeName);
                  }),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showThemeDialog(context, themeService, localization),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Language section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    localization.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Obx(() => Text(controller.currentLanguageName)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showLanguageDialog(context, controller, localization),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App info section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    localization.about,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('${localization.version}: 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context, localization),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Statistics
          Obx(
            () => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Total Contacts',
                          controller.totalContacts.toString(),
                          Icons.contacts,
                        ),
                        _buildStatItem(
                          context,
                          'Favorites',
                          controller.totalFavorites.toString(),
                          Icons.favorite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeService themeService,
    LocalizationService localization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => RadioListTile<AppThemeMode>(
                title: Text(localization.lightMode),
                value: AppThemeMode.light,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            Obx(
              () => RadioListTile<AppThemeMode>(
                title: Text(localization.darkMode),
                value: AppThemeMode.dark,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            Obx(
              () => RadioListTile<AppThemeMode>(
                title: Text(localization.systemMode),
                value: AppThemeMode.system,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsController controller,
    LocalizationService localization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () {
                controller.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Français'),
              leading: const Text('🇫🇷'),
              onTap: () {
                controller.changeLanguage('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Español'),
              leading: const Text('🇪🇸'),
              onTap: () {
                controller.changeLanguage('es');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(
    BuildContext context,
    LocalizationService localization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.appName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${localization.version}: 1.0.0'),
            const SizedBox(height: 8),
            Text('${localization.developer}: Datum Developer'),
            const SizedBox(height: 16),
            const Text(
              'A beautiful and modern address book app built with Flutter, featuring dark/light themes, multi-language support, and local storage with Hive.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
