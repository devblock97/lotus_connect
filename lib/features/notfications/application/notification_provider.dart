import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/notfications/data/datasources/notification_remote_data_source.dart';
import 'package:lotus_connect/features/notfications/data/repositories/notification_repository_impl.dart';
import 'package:lotus_connect/features/notfications/domain/repositories/notification_repository.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/get_notifications_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/mark_notification_read_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/register_device_token_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/unregister_device_token_use_case.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

final getNotificationUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

final registerDeviceTokenUseCaseProvider =
    Provider<RegisterDeviceTokenUseCase>((ref) {
  return RegisterDeviceTokenUseCase(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

final unregisterDeviceTokenUseCaseProvider =
    Provider<UnregisterDeviceTokenUseCase>((ref) {
  return UnregisterDeviceTokenUseCase(
    repository: ref.watch(notificationRepositoryProvider),
  );
});
