import 'package:drift/drift.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/core/services/storage/secure_storage_service.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';

abstract class SettingLocalDataSource {
  Future<AppSettings> getAppSettings();

  Future<void> updateAppSettings(AppSettings settings);
}

typedef SettingsLocalDataSource = SettingLocalDataSource;

class SettingsLocalDataSourceImpl implements SettingLocalDataSource {
  SettingsLocalDataSourceImpl(this._db, this._secureStorage);

  final AppDatabase _db;
  final SecureStorageService _secureStorage;

  @override
  Future<AppSettings> getAppSettings() async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((tbl) => tbl.id.equals('default')))
        .getSingleOrNull();

    var accessToken = '';
    var refreshToken = '';
    try {
      accessToken = await _secureStorage.getAccessToken();
      refreshToken = await _secureStorage.getRefreshToken();
    } on Object catch (_) {
      // Fallback if native secure storage plugin is not yet linked (e.g. hot restart)
    }

    if (row == null) {
      return AppSettings(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (row.accessToken.isNotEmpty || row.refreshToken.isNotEmpty) {
      if (accessToken.isEmpty) accessToken = row.accessToken;
      if (refreshToken.isEmpty) refreshToken = row.refreshToken;

      try {
        await _secureStorage.saveSecrets(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        await (_db.update(_db.appSettingsTable)
              ..where((tbl) => tbl.id.equals('default')))
            .write(
          const AppSettingsTableCompanion(
            accessToken: Value(''),
            refreshToken: Value(''),
          ),
        );
      } on Object catch (_) {
        // Keep in-memory token values even if secure storage write fails
      }
    }

    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == row.themeMode,
      orElse: () => AppThemeMode.dark,
    );

    return AppSettings(
      themeMode: themeMode,
      languageCode: row.languageCode,
      activeAiProvider: row.activeAiProvider,
      activeAiModel: row.activeAiModel,
      localLlmBaseUrl: row.localLlmBaseUrl,
      systemPrompt: row.systemPrompt,
      accessToken: accessToken,
      refreshToken: refreshToken,
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
    var savedToSecureStorage = false;
    try {
      await _secureStorage.saveSecrets(
        accessToken: settings.accessToken,
        refreshToken: settings.refreshToken,
      );
      savedToSecureStorage = true;
    } on Object catch (_) {
      // Fallback if plugin is not registered before a full cold rebuild
    }

    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            id: 'default',
            themeMode: Value(settings.themeMode.name),
            languageCode: Value(settings.languageCode),
            activeAiProvider: Value(settings.activeAiProvider),
            activeAiModel: Value(settings.activeAiModel),
            localLlmBaseUrl: Value(settings.localLlmBaseUrl),
            systemPrompt: Value(settings.systemPrompt),
            accessToken:
                Value(savedToSecureStorage ? '' : settings.accessToken),
            refreshToken:
                Value(savedToSecureStorage ? '' : settings.refreshToken),
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
