import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/auth/data/models/auth_response_model.dart';
import 'package:lotus_connect/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? platform,
    String? deviceToken,
  });

  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await dioClient.post<dynamic>(
        '/auth/register',
        data: {
          'username': username,
          if (fullName != null) 'fullName': fullName,
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      final data = response.data;
      var errorMessage = 'Registration failed';
      if (data is Map<String, dynamic>) {
        errorMessage = data['error'] as String? ??
            data['message'] as String? ??
            errorMessage;
      }
      throw ServerException(errorMessage);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to register: $e');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? platform,
    String? deviceToken,
  }) async {
    try {
      debugPrint('device token: $deviceToken');
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (platform != null) 'platform': platform,
          if (deviceToken != null) 'deviceToken': deviceToken,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      final data = response.data;
      var errorMessage = 'Failed to login';
      if (data is Map<String, dynamic>) {
        errorMessage = data['error'] as String? ??
            data['message'] as String? ??
            errorMessage;
      }
      throw ServerException(errorMessage);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to login: $e');
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await dioClient.post<dynamic>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on Object catch (e) {
      AppLogger.error('Logout request failed: $e');
    }
  }
}
