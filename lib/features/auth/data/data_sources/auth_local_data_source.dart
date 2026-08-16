import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';

/// Local data source contract for authentication session & token persistence.
abstract class AuthLocalDataSource {
  /// Saves authenticated user session tokens and credentials.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required String email,
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
  }) async {
    await _ref.read(settingsProvider.notifier).setSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
          username: username,
          email: email,
        );
  }

  @override
  Future<void> clearSession() async {
    await _ref.read(settingsProvider.notifier).clearTokens();
  }

  @override
  Future<User?> getCachedUser() async {
    final settings = _ref.read(settingsProvider);
    if (settings.accessToken.isNotEmpty && settings.username.isNotEmpty) {
      return User(
        id: settings.userId,
        username: settings.username,
        email: settings.email,
      );
    }
    return null;
  }

  @override
  Future<String?> getAccessToken() async {
    final token = _ref.read(settingsProvider).accessToken;
    return token.isNotEmpty ? token : null;
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = _ref.read(settingsProvider).refreshToken;
    return token.isNotEmpty ? token : null;
  }
}
