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
    this.errorMessage,
    this.cursor,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final String? errorMessage;
  final String? cursor;
  final bool hasReachedMax;
  final bool isLoadingMore;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
    String? cursor,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      cursor: cursor ?? this.cursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
        cursor: notifications.last.id,
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
        state = state.copyWith(errorMessage: error.message);
      }, (data) {
        state = state.copyWith(
          notifications: data,
          isLoading: false,
          cursor: data.last.id,
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
          cursor: mergeNotifications.last.id,
          hasReachedMax: notifications.length < 10,
        );
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
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
    try {
      final result = await _readNotificationUseCase(
        ReadNotificationParam(notificationId: notificationId),
      );
      result.fold((error) {
        AppLogger.debug('read notification error: ${error.message}');
        state = state.copyWith(errorMessage: error.message);
      }, (success) {
        AppLogger.debug('read notification success: ${success.message}');
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        state = state.copyWith(notifications: updated);
      });
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong, please try again!',
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
