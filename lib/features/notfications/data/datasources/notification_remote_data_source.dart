import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/notfications/application/notifications_notifier.dart';

abstract class NotificationRemoteDataSource {
  Future<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  });

  Future<ResponseEntityBase> unregisterDeviceToken({String? token});

  Future<List<AppNotification>> getNotifications();

  Future<ResponseEntityBase> markNotificationRead();

  Future<ResponseEntityBase> readNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dioClient.get('/users/notifications');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map(
              (n) => AppNotification.fromJson(n as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception(const ServerFailure('Failed to load notifications'));
    } on Object catch (_) {
      throw Exception(const ServerFailure('Failed to load notifications'));
    }
  }

  @override
  Future<ResponseEntityBase> markNotificationRead() async {
    try {
      final response = await _dioClient.get('/users/notifications/read');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw Exception(const ServerFailure('Failed to mark notification read'));
    } on Object catch (_) {
      throw Exception(const ServerFailure('Failed to mark notification read'));
    }
  }

  @override
  Future<ResponseEntityBase> registerDeviceToken({
    String? token,
    String? platform,
  }) async {
    try {
      final response = await _dioClient.post(
        '/users/devices',
        data: {
          'token': token,
          'platform': platform,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw Exception(const ServerFailure('Failed to register device token'));
    } on Object catch (_) {
      throw Exception(const ServerFailure('Failed to register device token'));
    }
  }

  @override
  Future<ResponseEntityBase> unregisterDeviceToken({String? token}) async {
    try {
      final response = await _dioClient.delete(
        '/users/devices',
        data: {
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw Exception(const ServerFailure('Failed to unregister device token'));
    } on Object catch (_) {
      throw Exception(const ServerFailure('Failed to unregister device token'));
    }
  }

  @override
  Future<ResponseEntityBase> readNotification(String notificationId) async {
    try {
      final response =
          await _dioClient.post('/users/notifications/$notificationId/read');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ResponseEntityBase.fromJson(data);
      }
      throw Exception(const ServerFailure('Failed to read notification'));
    } on Object catch (_) {
      throw Exception(const ServerFailure('Failed to read notification'));
    }
  }
}
