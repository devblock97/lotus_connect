import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/notifications/application/notification_provider.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/get_notifications_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/mark_notification_read_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/read_notification_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/register_device_token_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/unregister_device_token_use_case.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.activeFilter = NotificationFilter.all,
    this.searchQuery = '',
    this.errorMessage,
    this.cursor,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final String? errorMessage;
  final String? cursor;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final NotificationFilter activeFilter;
  final String searchQuery;

  /// Number of unread notifications currently in state.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Notifications filtered by [activeFilter] and [searchQuery].
  List<AppNotification> get filteredNotifications {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    return notifications.where((notification) {
      if (!notification.matchesFilter(activeFilter)) {
        return false;
      }
      if (normalizedQuery.isNotEmpty) {
        final titleMatch =
            notification.title.toLowerCase().contains(normalizedQuery);
        final bodyMatch =
            notification.body.toLowerCase().contains(normalizedQuery);
        final actorMatch =
            notification.actorName?.toLowerCase().contains(normalizedQuery) ??
                false;
        return titleMatch || bodyMatch || actorMatch;
      }
      return true;
    }).toList();
  }

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
    String? cursor,
    bool? hasReachedMax,
    bool? isLoadingMore,
    NotificationFilter? activeFilter,
    String? searchQuery,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      cursor: cursor ?? this.cursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier({
    required GetNotificationsUseCase getNotificationUseCase,
    required MarkNotificationReadUseCase markNotificationReadUseCase,
    required RegisterDeviceTokenUseCase registerDeviceTokenUseCase,
    required UnregisterDeviceTokenUseCase unregisterDeviceTokenUseCase,
    required ReadNotificationUseCase readNotificationUseCase,
    Duration debounceDuration = const Duration(milliseconds: 300),
  })  : _getNotificationsUseCase = getNotificationUseCase,
        _markNotificationReadUseCase = markNotificationReadUseCase,
        _registerDeviceTokenUseCase = registerDeviceTokenUseCase,
        _unregisterDeviceTokenUseCase = unregisterDeviceTokenUseCase,
        _readNotificationUseCase = readNotificationUseCase,
        _debounceDuration = debounceDuration,
        super(const NotificationsState()) {
    loadNotifications();
  }

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;
  final UnregisterDeviceTokenUseCase _unregisterDeviceTokenUseCase;
  final ReadNotificationUseCase _readNotificationUseCase;

  final Duration _debounceDuration;
  Timer? _debounceTimer;
  Completer<void>? _debounceCompleter;

  @visibleForTesting
  bool get isDebouncing => _debounceTimer?.isActive ?? false;

  final int _pageSize = 10;

  void setFilter(NotificationFilter filter) {
    if (state.activeFilter == filter) return;
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refreshNotifications() async {
    _cancelDebounce();
    state = state.copyWith(isLoading: true);

    final result = await _getNotificationsUseCase(
      GetNotificationParam(limit: _pageSize),
    );

    result.fold((failure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
    }, (notifications) {
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        cursor: notifications.isNotEmpty ? notifications.last.id : null,
        hasReachedMax: notifications.length < _pageSize,
      );
    });
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _getNotificationsUseCase(
        GetNotificationParam(limit: _pageSize),
      );
      result.fold((error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      }, (data) {
        state = state.copyWith(
          notifications: data,
          isLoading: false,
          cursor: data.isNotEmpty ? data.last.id : null,
          hasReachedMax: data.length < _pageSize,
        );
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  Future<void> loadMoreNotifications({bool immediate = false}) {
    if (state.hasReachedMax || state.isLoading) {
      return Future.value();
    }

    _debounceTimer?.cancel();
    _debounceCompleter ??= Completer<void>();

    if (immediate || _debounceDuration == Duration.zero) {
      _executeLoadMore();
    } else {
      _debounceTimer = Timer(_debounceDuration, _executeLoadMore);
    }

    return _debounceCompleter!.future;
  }

  Future<void> _executeLoadMore() async {
    if (state.hasReachedMax || state.isLoading) {
      _completeDebounce();
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _getNotificationsUseCase(
        GetNotificationParam(cursor: state.cursor),
      );
      result.fold((error) {
        state = state.copyWith(
          errorMessage: error.message,
          isLoadingMore: false,
        );
      }, (notifications) {
        final mergeNotifications = [...state.notifications, ...notifications];
        state = state.copyWith(
          notifications: mergeNotifications,
          isLoadingMore: false,
          cursor: mergeNotifications.isNotEmpty
              ? mergeNotifications.last.id
              : state.cursor,
          hasReachedMax: notifications.length < _pageSize,
        );
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('ServerException', ''),
      );
    }

    _completeDebounce();
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _completeDebounce();
  }

  void _completeDebounce() {
    if (_debounceCompleter != null && !_debounceCompleter!.isCompleted) {
      _debounceCompleter!.complete();
    }
    _debounceCompleter = null;
  }

  Future<void> readNotification(String notificationId) async {
    // Optimistically mark as read for responsive UI
    final previous = state.notifications;
    final optimistic = state.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: optimistic);

    try {
      final result = await _readNotificationUseCase(
        ReadNotificationParam(notificationId: notificationId),
      );
      result.fold((error) {
        AppLogger.debug('read notification error: ${error.message}');
        state = state.copyWith(
          notifications: previous,
          errorMessage: error.message,
        );
      }, (success) {
        AppLogger.debug('read notification success: ${success.message}');
      });
    } on Object {
      state = state.copyWith(
        notifications: previous,
        isLoading: false,
        errorMessage: 'Something went wrong, please try again!',
      );
    }
  }

  /// Toggles the read status of a single notification.
  Future<void> toggleReadStatus(String notificationId) async {
    final index = state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final target = state.notifications[index];
    if (!target.isRead) {
      await readNotification(notificationId);
    } else {
      final updated = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: false);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updated);
    }
  }

  /// Removes a notification locally (with ability to undo via
  /// [restoreNotification]).
  int removeNotification(String notificationId) {
    final index = state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return -1;

    final updated = List<AppNotification>.from(state.notifications)
      ..removeAt(index);
    state = state.copyWith(notifications: updated);
    return index;
  }

  /// Restores a previously removed notification at [index].
  void restoreNotification(AppNotification notification, {int? index}) {
    if (state.notifications.any((n) => n.id == notification.id)) return;
    final updated = List<AppNotification>.from(state.notifications);
    final insertIndex =
        (index != null && index >= 0 && index <= updated.length) ? index : 0;
    updated.insert(insertIndex, notification);
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllRead() async {
    final previous = state.notifications;
    final optimistic =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: optimistic);

    try {
      final result = await _markNotificationReadUseCase(const NoParams());
      await result.fold((error) {
        state = state.copyWith(
          notifications: previous,
          errorMessage: error.message,
        );
      }, (data) async {
        await loadNotifications();
      });
    } on Object catch (e) {
      state = state.copyWith(
        notifications: previous,
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
      throw Exception('Failed to unregister device token with token: $token');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _completeDebounce();
    super.dispose();
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
    readNotificationUseCase: ref.watch(readNotificationUseCaseProvider),
  );
});
