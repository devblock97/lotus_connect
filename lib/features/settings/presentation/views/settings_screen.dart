import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/features/auth/application/auth_notifier.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/presentation/widgets/setting_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Supported languages map.
const Map<String, String> _supportedLanguages = {
  'en': 'English',
  'vi': 'Tiếng Việt',
  'ja': '日本語',
  'zh': '中文',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settings = settingsState.settings;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final loc = AppLocalizations.of(context)!;

    debugPrint('setting screen: ${settingsState.isSuccess}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.profileSettings,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          SettingCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: settings.avatarUrl.isNotEmpty
                                ? NetworkImage(settings.avatarUrl)
                                : null,
                            child: settings.avatarUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            settings.email,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // GENERAL SECTION
          _buildSectionTitle(context, loc.general),
          SettingCard(
            child: Column(
              children: [
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.edit),
                  title: Text(loc.editProfile),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.notifications_none),
                  title: Text(loc.notificationSettings),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.language),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    underline: const SizedBox(),
                    items: _supportedLanguages.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setLanguage(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // APPEARANCE SECTION
          _buildSectionTitle(context, loc.appearance),
          SettingCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.themeSelection,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          mode: AppThemeMode.light,
                          title: loc.themeLight,
                          isSelected: settings.themeMode == AppThemeMode.light,
                          bgColor: const Color(0xFFFFFFFF),
                          onTap: () =>
                              notifier.setThemeMode(AppThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          mode: AppThemeMode.dark,
                          title: loc.themeDark,
                          isSelected: settings.themeMode == AppThemeMode.dark,
                          bgColor: const Color(0xFF1E1E22),
                          onTap: () => notifier.setThemeMode(AppThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          mode: AppThemeMode.sepia,
                          title: loc.themeSepia,
                          isSelected: settings.themeMode == AppThemeMode.sepia,
                          bgColor: const Color(0xFFF4ECD8),
                          onTap: () =>
                              notifier.setThemeMode(AppThemeMode.sepia),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // INFORMATION SECTION
          _buildSectionTitle(context, loc.information),
          SettingCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.about),
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    loc.logOut,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required AppThemeMode mode,
    required String title,
    required bool isSelected,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: mode == AppThemeMode.light
                    ? Colors.black
                    : (mode == AppThemeMode.dark
                        ? Colors.white
                        : const Color(0xFF4A3B32)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
