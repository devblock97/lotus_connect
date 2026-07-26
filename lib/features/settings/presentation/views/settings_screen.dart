import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

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
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  label: const Text('Edit Profile'),
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
          _buildSectionTitle(context, 'AI ENGINE SETTINGS'),
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
                      const Text(
                        'Active AI Engine',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: settings.activeAiProvider,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'gemini',
                            child: Text('Google Gemini (Live)'),
                          ),
                          DropdownMenuItem(
                            value: 'local',
                            child: Text('Local LLM (Ollama)'),
                          ),
                          DropdownMenuItem(
                            value: 'mock',
                            child: Text('Neural AI (Mock)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            notifier.setAiProvider(val);
                            // Auto-set first available model for selected provider
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
                    const Text(
                      'Local LLM Endpoint (Ollama / LM Studio)',
                      style: TextStyle(
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
                      'Stored in local database. Make sure Ollama/LM Studio is running.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else if (settings.activeAiProvider == 'gemini') ...[
                    const Text(
                      'Google AI Studio API Key',
                      style: TextStyle(
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
                        hintText: 'Paste AI Studio API Key',
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
                                notifier.setGeminiApiKey(_apiKeyController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gemini API Key saved to database!'),
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
                      'Stored securely in local SQLite database for future sessions',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Mock mode does not require any endpoint configuration.',
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
          _buildSectionTitle(context, 'APPEARANCE'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.palette_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Theme Selection',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
          _buildSectionTitle(context, 'GENERAL'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'vi',
                        child: Text('Tiếng Việt'),
                      ),
                    ],
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
          _buildSectionTitle(context, 'INFORMATION'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About LotusConnect'),
                  trailing: Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
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
