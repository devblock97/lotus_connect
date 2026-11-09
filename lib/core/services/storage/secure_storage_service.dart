import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';

  Future<String> getAccessToken() async =>
      await _storage.read(key: _kAccessToken) ?? '';

  Future<String> getRefreshToken() async =>
      await _storage.read(key: _kRefreshToken) ?? '';

  Future<void> saveSecrets({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      if (accessToken.isEmpty)
        _storage.delete(key: _kAccessToken)
      else
        _storage.write(key: _kAccessToken, value: accessToken),
      if (refreshToken.isEmpty)
        _storage.delete(key: _kRefreshToken)
      else
        _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String> getOrCreateDatabaseKey() async {
    const keyName = 'db.encryption_key';
    var key = await _storage.read(key: keyName);
    if (key == null || key.isEmpty) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _storage.write(key: keyName, value: key);
    }
    return key;
  }

  Future<void> clearAuthTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
