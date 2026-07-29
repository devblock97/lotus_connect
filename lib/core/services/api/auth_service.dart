import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

/// Service interfacing withauth REST endpoints on the Rust backend.
class AuthService {
  AuthService({required this.dioClient});

  final DioClient dioClient;

  /// Registers a new user.
  Future<User> register({
    required String username,
    String? fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'username': username,
          if (fullName != null) 'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Registration failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to register: $e');
    }
  }

  /// Logs in a user, returning access and refresh tokens along with User.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? platform,
    String? deviceToken,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (platform != null) 'platform': platform,
          if (deviceToken != null) 'deviceToken': deviceToken,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        return {
          'user': user,
          'accessToken': data['accessToken'] as String,
          'refreshToken': data['refreshToken'] as String,
        };
      }
      throw const ServerException('Login failed');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to login: $e');
    }
  }

  /// Logs out the user by invalidating the refresh token.
  Future<void> logout({required String refreshToken}) async {
    try {
      await dioClient.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } catch (e) {
      debugPrint('Logout request failed: $e');
    }
  }
}
