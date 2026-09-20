import 'package:drift/drift.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';

abstract class SettingLocalDataSource {
  Future<AppSettings> getAppSettings();

  Future<void> updateAppSettings(AppSettings settings);
}

typedef SettingsLocalDataSource = SettingLocalDataSource;

class SettingsLocalDataSourceImpl implements SettingLocalDataSource {
  SettingsLocalDataSourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<AppSettings> getAppSettings() async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((tbl) => tbl.id.equals('default')))
        .getSingleOrNull();

    if (row == null) return const AppSettings();

    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == row.themeMode,
      orElse: () => AppThemeMode.dark,
    );

    return AppSettings(
      themeMode: themeMode,
      languageCode: row.languageCode,
      activeAiProvider: row.activeAiProvider,
      activeAiModel: row.activeAiModel,
      geminiApiKey: row.geminiApiKey,
      localLlmBaseUrl: row.localLlmBaseUrl,
      systemPrompt: row.systemPrompt,
      accessToken: row.accessToken,
      refreshToken: row.refreshToken,
      serverHost: row.serverHost,
      userId: row.userId,
      username: row.username,
      email: row.email,
      fullName: row.fullName,
      avatarUrl: row.avatarUrl,
    );
  }

  @override
  Future<void> updateAppSettings(AppSettings settings) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            id: 'default',
            themeMode: Value(settings.themeMode.name),
            languageCode: Value(settings.languageCode),
            activeAiProvider: Value(settings.activeAiProvider),
            activeAiModel: Value(settings.activeAiModel),
            geminiApiKey: Value(settings.geminiApiKey),
            localLlmBaseUrl: Value(settings.localLlmBaseUrl),
            systemPrompt: Value(settings.systemPrompt),
            accessToken: Value(settings.accessToken),
            refreshToken: Value(settings.refreshToken),
            serverHost: Value(settings.serverHost),
            userId: Value(settings.userId),
            username: Value(settings.username),
            email: Value(settings.email),
            fullName: Value(settings.fullName),
            avatarUrl: Value(settings.avatarUrl),
          ),
        );
  }
}
