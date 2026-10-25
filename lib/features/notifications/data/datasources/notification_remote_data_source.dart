import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRemoteDataSource {
  Future<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  });

  Future<ResponseEntityBase> unregisterDeviceToken({String? token});

  Future<List<AppNotification>> getNotifications(String? cursor, int limit);

  Future<ResponseEntityBase> markNotificationRead();

  Future<ResponseEntityBase> readNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<AppNotification>> getNotifications(
    String? cursor,
    int limit,
  ) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.notifications,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map(
              (n) => AppNotification.fromJson(n as Map<String, dynamic>),
            )
            .toList();
      }
      throw ServerException(
        'Failed to load notifications: status ${response.statusCode}',
      );
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Failed to load notifications: $e');
    }
  }

  @override
  Future<ResponseEntityBase> markNotificationRead() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.markAllNotificationsRead,
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw ServerException(
        'Failed to mark notification read: status ${response.statusCode}',
      );
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Failed to mark notification read: $e');
    }
  }

  @override
  Future<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.devices,
        data: {
          'token': token,
          'platform': platform,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw ServerException(
        'Failed to register device token: status ${response.statusCode}',
      );
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Failed to register device token: $e');
    }
  }

  @override
  Future<ResponseEntityBase> unregisterDeviceToken({String? token}) async {
    try {
      final response = await _dioClient.delete(
        ApiConstants.devices,
        data: {
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw ServerException(
        'Failed to unregister device token: status ${response.statusCode}',
      );
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Failed to unregister device token: $e');
    }
  }

  @override
  Future<ResponseEntityBase> readNotification(String notificationId) async {
    try {
      final response =
          await _dioClient.post(ApiConstants.readNotification(notificationId));
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw ServerException(
        'Failed to read notification: status ${response.statusCode}',
      );
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException('Failed to read notification: $e');
    }
  }
}
