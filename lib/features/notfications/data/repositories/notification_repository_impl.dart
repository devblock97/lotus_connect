import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/notfications/data/datasources/notification_remote_data_source.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;
  final NotificationRemoteDataSource _remoteDataSource;

  @override
  FutureResult<List<AppNotification>> getNotifications() async {
    try {
      final result = await _remoteDataSource.getNotifications();
      return Right(result);
    } on Object catch (_) {
      return const Left(ServerFailure('Failed to load notifications'));
    }
  }

  @override
  FutureResult<ResponseEntityBase> markNotificationRead() async {
    try {
      final result = await _remoteDataSource.markNotificationRead();
      return Right(result);
    } on Object catch (_) {
      return const Left(ServerFailure('Failed to mark notification read'));
    }
  }

  @override
  FutureResult<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  }) async {
    try {
      final result = await _remoteDataSource.registerDeviceToken(
        token: token,
        platform: platform,
      );
      return Right(result);
    } on Object catch (_) {
      return const Left(ServerFailure('Failed to register device token'));
    }
  }

  @override
  FutureResult<ResponseEntityBase> unregisterDeviceToken({
    String? token,
  }) async {
    try {
      final result = await _remoteDataSource.unregisterDeviceToken(
        token: token,
      );
      return Right(result);
    } on Object catch (_) {
      return const Left(ServerFailure('Failed to unregister device token'));
    }
  }

  @override
  FutureResult<ResponseEntityBase> readNotification(
    String notificationId,
  ) async {
    try {
      final result = await _remoteDataSource.readNotification(notificationId);
      return Right(result);
    } on Object catch (_) {
      return const Left(ServerFailure('Failed to read notification'));
    }
  }
}
