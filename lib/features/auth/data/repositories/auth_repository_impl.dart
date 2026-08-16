import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/services/notification/push_notification_service.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:lotus_connect/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required PushNotificationService pushNotificationService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _pushNotificationService = pushNotificationService;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final PushNotificationService _pushNotificationService;

  @override
  FutureResult<User> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to register: $e', e));
    }
  }

  @override
  FutureResult<User> login({
    required String email,
    required String password,
    String? platform,
    String? deviceToken,
  }) async {
    try {
      final authResponse = await _remoteDataSource.login(
        email: email,
        password: password,
        platform: platform,
        deviceToken: deviceToken,
      );

      // Persist auth session via AuthLocalDataSource
      await _localDataSource.saveSession(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
        username: authResponse.user.username,
        email: authResponse.user.email,
      );

      // Sync FCM token to backend database for newly authenticated user
      await _pushNotificationService.syncDeviceToken();

      return Right(authResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to login: $e', e));
    }
  }

  @override
  FutureResult<void> logout() async {
    try {
      // Unregister FCM device token from backend
      try {
        await _pushNotificationService.unregisterDeviceToken();
      } on Object catch (_) {
        // Degrade gracefully
      }

      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(refreshToken: refreshToken);
      }

      await _localDataSource.clearSession();
      return const Right(null);
    } on Object catch (e) {
      return Left(ServerFailure('Failed to logout: $e', e));
    }
  }

  @override
  FutureResult<User?> getCachedUser() async {
    try {
      final user = await _localDataSource.getCachedUser();
      return Right(user);
    } on Object catch (e) {
      return Left(CacheFailure('Failed to load cached user: $e', e));
    }
  }
}
