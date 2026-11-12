import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/theme/app_size.dart';
import 'package:lotus_connect/features/auth/application/auth_notifier.dart';
import 'package:lotus_connect/features/profile/application/profile_providers.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:lotus_connect/features/profile/presentation/views/profile_screen.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/presentation/widgets/setting_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Map<String, String> _supportedLanguages(AppLocalizations loc) => {
        'en': loc.languageEnglish,
        'vi': loc.languageVietnamese,
        'ja': loc.languageJapanese,
        'zh': loc.languageChinese,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settings = settingsState.settings;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    final supportedLanguages = _supportedLanguages(loc);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.profileSettings,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: AppPadding.screen,
        children: [
          // Profile Header Card
          SettingCard(
            child: InkWell(
              borderRadius: AppRadius.card,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: Padding(
                padding: AppPadding.card,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: AppSize.avatarXxl / 2,
                              backgroundColor: Colors.grey,
                              backgroundImage: settings.avatarUrl.isNotEmpty
                                  ? NetworkImage(settings.avatarUrl)
                                  : null,
                              child: settings.avatarUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: AppSize.iconXxl,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: AppSize.none,
                              right: AppSize.none,
                              child: Container(
                                padding: AppPadding.xxs,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.blue,
                                  size: AppSize.iconSm,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppGap.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings.fullName.isNotEmpty
                                    ? settings.fullName
                                    : (settings.username.isNotEmpty
                                        ? settings.username
                                        : loc.unknownUser),
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
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    AppGap.vMd,
                  ],
                ),
              ),
            ),
          ),
          AppGap.vXxl,

          // GENERAL SECTION
          _buildSectionTitle(context, loc.general),
          SettingCard(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    final currentProfile =
                        ref.read(myProfileNotifierProvider).profile ??
                            UserProfile(
                              id: settings.userId,
                              username: settings.username,
                              fullName: settings.fullName.isNotEmpty
                                  ? settings.fullName
                                  : null,
                              email: settings.email,
                              avatarUrl: settings.avatarUrl.isNotEmpty
                                  ? settings.avatarUrl
                                  : null,
                              isSelf: true,
                            );
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          initialProfile: currentProfile,
                        ),
                      ),
                    );
                  },
                  leading: const Icon(Icons.edit),
                  title: Text(loc.editProfile),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: AppSize.dividerThickness),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.notifications_none),
                  title: Text(loc.notificationSettings),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(height: AppSize.dividerThickness),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.language),
                  trailing: DropdownButton<String>(
                    value: supportedLanguages.containsKey(settings.languageCode)
                        ? settings.languageCode
                        : 'en',
                    underline: AppGap.shrink,
                    items: supportedLanguages.entries.map((entry) {
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
          AppGap.vLg,

          // APPEARANCE SECTION
          _buildSectionTitle(context, loc.appearance),
          SettingCard(
            child: Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: AppSize.iconSm),
                      AppGap.hSm,
                      Text(
                        loc.themeSelection,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  AppGap.vLg,
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
                      AppGap.hSm,
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
                      AppGap.hSm,
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
          AppGap.vLg,

          // INFORMATION SECTION
          _buildSectionTitle(context, loc.information),
          SettingCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.about),
                  trailing: Text(
                    loc.appVersion('1.0.0'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: AppSize.dividerThickness),
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
      padding: const EdgeInsets.only(
        left: AppSize.xs,
        bottom: AppSize.sm,
        top: AppSize.sm,
      ),
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
        padding: AppPadding.cardCompact,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.md,
          border: AppBorder.all(
            isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? AppSize.borderThick : AppSize.borderThin,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: AppSize.xxxl,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: AppRadius.sm,
              ),
            ),
            AppGap.vSm,
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
