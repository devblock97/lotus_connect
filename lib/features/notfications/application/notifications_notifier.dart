import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/notfications/application/notification_provider.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/get_notifications_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/mark_notification_read_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/register_device_token_use_case.dart';
import 'package:lotus_connect/features/notfications/domain/usecase/unregister_device_token_use_case.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
}

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier({
    required GetNotificationsUseCase getNotificationUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required RegisterDeviceTokenUseCase registerDeviceTokenUseCase,
    required UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase,
  })  : _getNotificationsUseCase = getNotificationUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        _registerDeviceTokenUseCase = registerDeviceTokenUseCase,
        _unregisterDeviceTokenUseCase = unregisterDeviceTokenUseCase,
        super(const NotificationsState()) {
    loadNotifications();
  }

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;
  final UnregisterDeviceTokenUseCase _unregisterDeviceTokenUseCase;

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _getNotificationsUseCase(const NoParams());
      notifications.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (data) {
        state = state.copyWith(notifications: data, isLoading: false);
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  Future<void> markAllRead() async {
    try {
      final result = await _markNotificationReadUseCase(const NoParams());
      await result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (data) async {
        await loadNotifications();
      });
    } on Object catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  Future<void> registerDeviceToken(String token, String platform) async {
    try {
      await _registerDeviceTokenUseCase(
        RegisterDeviceTokenParam(
          token: token,
          platform: platform,
        ),
      );
    } on Object catch (_) {
      throw Exception('Failed to register device token '
          'with token: $token on platform: $platform');
    }
  }

  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _unregisterDeviceTokenUseCase(
        UnregisterDeviceTokenParam(token: token),
      );
    } on Object catch (_) {
      throw Exception('Failed to unregister device token '
          'with token: $token');
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(
    getNotificationUseCase: ref.watch(getNotificationUseCaseProvider),
    markNotificationReadUseCase: ref.watch(markNotificationReadUseCaseProvider),
    registerDeviceTokenUseCase: ref.watch(registerDeviceTokenUseCaseProvider),
    unregisterDeviceTokenUseCase:
        ref.watch(unregisterDeviceTokenUseCaseProvider),
  );
});
