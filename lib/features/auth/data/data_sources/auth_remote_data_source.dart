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
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Registration failed');
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
      final response = await dioClient.post<dynamic>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (platform != null) 'platform': platform,
          if (deviceToken != null) 'deviceToken': deviceToken,
        },
      );
      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ServerException('Login failed');
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
