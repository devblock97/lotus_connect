import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';

/// Supported languages map.
const Map<String, String> _supportedLanguages = {
  'en': 'English',
  'vi': 'Tiếng Việt',
  'ja': '日本語',
  'zh': '中文',
};

/// Profile & Settings View matching image3 design with Google AI Studio key configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _localUrlController;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _apiKeyController = TextEditingController(text: settings.geminiApiKey);
    _localUrlController = TextEditingController(text: settings.localLlmBaseUrl);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _localUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final loc = AppLocalizations.of(context)!;

    // Keep controllers updated if settings change externally
    if (_apiKeyController.text != settings.geminiApiKey &&
        !FocusScope.of(context).hasFocus) {
      _apiKeyController.text = settings.geminiApiKey;
    }
    if (_localUrlController.text != settings.localLlmBaseUrl &&
        !FocusScope.of(context).hasFocus) {
      _localUrlController.text = settings.localLlmBaseUrl;
    }

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
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
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
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alex Chen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Senior Product Designer & AI enthusiast. Exploring neural networks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(loc.editProfile),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // AI ENGINE SETTINGS SECTION
          _buildSectionTitle(context, loc.aiEngineSettings),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        loc.activeAiEngine,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: settings.activeAiProvider,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: 'gemini',
                            child: Text(loc.googleGeminiLive),
                          ),
                          DropdownMenuItem(
                            value: 'local',
                            child: Text(loc.localLlmOllama),
                          ),
                          DropdownMenuItem(
                            value: 'mock',
                            child: Text(loc.neuralAiMock),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            notifier.setAiProvider(val);
                            if (val == 'local') {
                              notifier.setAiModel('llama3');
                            } else if (val == 'gemini') {
                              notifier.setAiModel('gemini-1.5-flash');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Display settings based on chosen AI engine
                  if (settings.activeAiProvider == 'local') ...[
                    Text(
                      loc.localEndpoint,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _localUrlController,
                      onChanged: (val) {
                        notifier.setLocalLlmBaseUrl(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g. http://localhost:11434',
                        filled: true,
                        fillColor: theme.cardColor,
                        prefixIcon: const Icon(Icons.computer, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.ollamaRunningNotice,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else if (settings.activeAiProvider == 'gemini') ...[
                    Text(
                      loc.geminiApiKey,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      onChanged: (val) {
                        notifier.setGeminiApiKey(val);
                      },
                      decoration: InputDecoration(
                        hintText: loc.pasteApiKey,
                        filled: true,
                        fillColor: theme.cardColor,
                        prefixIcon: const Icon(Icons.key, size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              tooltip: 'Save Key',
                              onPressed: () {
                                notifier
                                    .setGeminiApiKey(_apiKeyController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(loc.keySaved),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.storedNotice,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      loc.noConfigRequired,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // APPEARANCE SECTION
          _buildSectionTitle(context, loc.appearance),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
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
                          title: 'Light',
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
                          title: 'Dark',
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
                          title: 'Sepia',
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

          // GENERAL SECTION
          _buildSectionTitle(context, loc.general),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Column(
              children: [
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

          // INFORMATION SECTION
          _buildSectionTitle(context, loc.information),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
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
                  onTap: () {},
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
          letterSpacing: 1.0,
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
