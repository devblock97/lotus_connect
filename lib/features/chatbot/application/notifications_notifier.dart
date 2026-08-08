import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';

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
  NotificationsNotifier(this._chatApiService)
      : super(const NotificationsState()) {
    loadNotifications();
  }

  final ChatApiService _chatApiService;

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _chatApiService.getNotifications();
      final notifications = list.map(AppNotification.fromJson).toList();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  Future<void> markAllRead() async {
    try {
      await _chatApiService.markNotificationsRead();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final apiService = ref.watch(chatApiServiceProvider);
  return NotificationsNotifier(apiService);
});
