import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/notifications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/notifications/domain/entities/app_notification.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/get_notifications_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/mark_notification_read_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/read_notification_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/register_device_token_use_case.dart';
import 'package:lotus_connect/features/notifications/domain/usecase/unregister_device_token_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

class MockRegisterDeviceTokenUseCase extends Mock
    implements RegisterDeviceTokenUseCase {}

class MockUnregisterDeviceTokenUseCase extends Mock
    implements UnregisterDeviceTokenUseCase {}

class MockReadNotificationUseCase extends Mock
    implements ReadNotificationUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetNotificationParam());
    registerFallbackValue(const ReadNotificationParam(notificationId: '1'));
    registerFallbackValue(const NoParams());
  });

  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkNotificationReadUseCase mockMarkNotificationReadUseCase;
  late MockRegisterDeviceTokenUseCase mockRegisterDeviceTokenUseCase;
  late MockUnregisterDeviceTokenUseCase mockUnregisterDeviceTokenUseCase;
  late MockReadNotificationUseCase mockReadNotificationUseCase;

  final sampleNotifications = <AppNotification>[
    AppNotification(
      id: 'n1',
      userId: 'u1',
      title: 'Alice Nguyen',
      body: 'liked your photo.',
      isRead: false,
      createdAt: DateTime(2026, 11, 2, 12),
      data: const {'type': 'like', 'actorName': 'Alice Nguyen'},
    ),
    AppNotification(
      id: 'n2',
      userId: 'u1',
      title: 'Bob Tran',
      body: 'sent you a friend request.',
      isRead: false,
      createdAt: DateTime(2026, 11, 2, 11),
      data: const {'type': 'friend_request', 'senderId': 'bob_1'},
    ),
    AppNotification(
      id: 'n3',
      userId: 'u1',
      title: 'Missed Call',
      body: 'You missed a voice call from Charlie.',
      isRead: true,
      createdAt: DateTime(2026, 11, 1, 9),
      data: const {'type': 'missed_call'},
    ),
  ];

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkNotificationReadUseCase = MockMarkNotificationReadUseCase();
    mockRegisterDeviceTokenUseCase = MockRegisterDeviceTokenUseCase();
    mockUnregisterDeviceTokenUseCase = MockUnregisterDeviceTokenUseCase();
    mockReadNotificationUseCase = MockReadNotificationUseCase();

    when(() => mockGetNotificationsUseCase(any())).thenAnswer(
      (_) async => Right(sampleNotifications),
    );
  });

  NotificationsNotifier createNotifier() {
    return NotificationsNotifier(
      getNotificationUseCase: mockGetNotificationsUseCase,
      markNotificationReadUseCase: mockMarkNotificationReadUseCase,
      registerDeviceTokenUseCase: mockRegisterDeviceTokenUseCase,
      unregisterDeviceTokenUseCase: mockUnregisterDeviceTokenUseCase,
      readNotificationUseCase: mockReadNotificationUseCase,
      debounceDuration: Duration.zero,
    );
  }

  group('AppNotification entity & Facebook-style classification', () {
    test('copyWith preserves data map and updates isRead', () {
      final original = sampleNotifications.first;
      final updated = original.copyWith(isRead: true);

      expect(updated.isRead, isTrue);
      expect(updated.data, equals(original.data));
      expect(updated.kind, NotificationKind.like);
    });

    test('matchesFilter categorizes notifications accurately', () {
      expect(
        sampleNotifications[0].matchesFilter(NotificationFilter.social),
        isTrue,
      );
      expect(
        sampleNotifications[1].matchesFilter(NotificationFilter.requests),
        isTrue,
      );
      expect(
        sampleNotifications[2].matchesFilter(NotificationFilter.callsAndChats),
        isTrue,
      );
      expect(
        sampleNotifications[2].matchesFilter(NotificationFilter.unread),
        isFalse,
      );
    });
  });

  group('NotificationsNotifier Facebook-style UX actions', () {
    test('loads notifications and computes unreadCount', () async {
      final notifier = createNotifier();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.notifications.length, 3);
      expect(notifier.state.unreadCount, 2);
    });

    test('filters notifications by category pill and search query', () async {
      final notifier = createNotifier();
      await Future<void>.delayed(Duration.zero);

      notifier.setFilter(NotificationFilter.unread);
      expect(notifier.state.filteredNotifications.length, 2);

      notifier.setFilter(NotificationFilter.requests);
      expect(notifier.state.filteredNotifications.length, 1);
      expect(notifier.state.filteredNotifications.first.id, 'n2');

      notifier
        ..setFilter(NotificationFilter.all)
        ..setSearchQuery('charlie');
      expect(notifier.state.filteredNotifications.length, 1);
      expect(notifier.state.filteredNotifications.first.id, 'n3');
    });

    test('removeNotification and restoreNotification support undo flow',
        () async {
      final notifier = createNotifier();
      await Future<void>.delayed(Duration.zero);

      final target = notifier.state.notifications[1];
      final removedIndex = notifier.removeNotification(target.id);

      expect(removedIndex, 1);
      expect(notifier.state.notifications.length, 2);

      notifier.restoreNotification(target, index: removedIndex);
      expect(notifier.state.notifications.length, 3);
      expect(notifier.state.notifications[1].id, target.id);
    });

    test('toggleReadStatus marks unread as read and read as unread', () async {
      when(() => mockReadNotificationUseCase(any())).thenAnswer(
        (_) async => const Right(ResponseEntityBase(message: 'Marked as read')),
      );

      final notifier = createNotifier();
      await Future<void>.delayed(Duration.zero);

      await notifier.toggleReadStatus('n1');
      expect(
        notifier.state.notifications.firstWhere((n) => n.id == 'n1').isRead,
        isTrue,
      );

      await notifier.toggleReadStatus('n1');
      expect(
        notifier.state.notifications.firstWhere((n) => n.id == 'n1').isRead,
        isFalse,
      );
    });
  });
}
