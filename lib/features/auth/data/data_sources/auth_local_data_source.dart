import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

/// Local data source contract for authentication session & token persistence.
abstract class AuthLocalDataSource {
  /// Saves authenticated user session tokens and credentials.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String email,
    required String fullName,
    required String avatarUrl,
  });

  /// Clears stored authentication tokens and resets session.
  Future<void> clearSession();

  /// Retrieves cached user profile from local storage if available.
  Future<User?> getCachedUser();

  /// Retrieves cached access token.
  Future<String?> getAccessToken();

  /// Retrieves cached refresh token.
  Future<String?> getRefreshToken();
}

/// Concrete implementation of [AuthLocalDataSource] using [Ref] to read settings store.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({required Ref ref}) : _ref = ref;

  final Ref _ref;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String email,
    required String fullName,
    required String avatarUrl,
  }) async {
    await _ref.read(settingsNotifierProvider.notifier).setSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
          username: username,
          email: email,
          fullName: fullName,
          avatarUrl: avatarUrl,
        );
  }

  @override
  Future<void> clearSession() async {
    await _ref.read(settingsNotifierProvider.notifier).clearTokens();
  }

  @override
  Future<User?> getCachedUser() async {
    final notifier = _ref.read(settingsNotifierProvider);
    if (notifier.settings.accessToken.isNotEmpty &&
        notifier.settings.username.isNotEmpty) {
      return User(
        id: notifier.settings.userId,
        username: notifier.settings.username,
        email: notifier.settings.email,
        fullName: notifier.settings.fullName,
        avatarUrl: notifier.settings.avatarUrl,
      );
    }
    return null;
  }

  @override
  Future<String?> getAccessToken() async {
    final token = _ref.read(settingsNotifierProvider).settings.accessToken;
    return token.isNotEmpty ? token : null;
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = _ref.read(settingsNotifierProvider).settings.refreshToken;
    return token.isNotEmpty ? token : null;
  }
}
