import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/core/services/websocket/websocket_sync_coordinator.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/application/active_call_notifier.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/application/calls_providers.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/repositories/calls_repository.dart';
import 'package:lotus_connect/features/calls/domain/usecases/accept_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/end_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/get_call_history_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/initiate_call_usecase.dart';
import 'package:lotus_connect/features/calls/domain/usecases/send_sdp_usecase.dart';
import 'package:lotus_connect/features/calls/presentation/views/calls_screen.dart';
import 'package:lotus_connect/features/chat/application/presence_notifier.dart';
import 'package:lotus_connect/features/contacts/application/contacts_notifier.dart';
import 'package:lotus_connect/features/contacts/application/friend_request_notifier.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/delete_friend_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_friend_requests_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/search_user_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/presentation/views/contacts_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/friend_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/views/history_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/history_card.dart';
import 'package:lotus_connect/features/notifications/application/notifications_notifier.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';
import 'package:lotus_connect/features/settings/domain/entities/app_settings.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:lotus_connect/main_shell_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockContactsRepository extends Mock implements ContactsRepository {}

class _MockCallsRepository extends Mock implements CallsRepository {}

class _MockSignalingService extends Mock implements WebRTCSignalingService {}

class _MockWebSocketService extends Mock implements WebSocketService {}

class _FakeNotificationsNotifier extends StateNotifier<NotificationsState>
    implements NotificationsNotifier {
  _FakeNotificationsNotifier() : super(const NotificationsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsNotifier extends StateNotifier<SettingsState>
    implements SettingsNotifier {
  _FakeSettingsNotifier([AppSettings settings = const AppSettings()])
      : super(SettingsState(settings: settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const webrtcChannel = MethodChannel('FlutterWebRTC.Method');
  const ringtoneChannel = MethodChannel('flutter_ringtone_player');

  late _MockContactsRepository mockContactsRepo;
  late _MockCallsRepository mockCallsRepo;
  late _MockSignalingService mockSignaling;
  late _MockWebSocketService mockWebSocket;
  late StreamController<WebRTCCallInvitation> invitationController;
  late StreamController<Map<String, dynamic>> acceptController;
  late StreamController<Map<String, dynamic>> endController;
  late StreamController<Map<String, dynamic>> sdpController;
  late StreamController<Map<String, dynamic>> iceController;
  late StreamController<Map<String, dynamic>> inviteAckController;

  const friendWithEmptyFullName = User(
    id: 'friend-1',
    username: 'alice',
    fullName: '',
    email: 'alice@lotus.io',
  );

  const testSettings = AppSettings(
    userId: 'me-1',
    username: 'me',
    fullName: 'Me User',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(webrtcChannel, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ringtoneChannel, (call) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(webrtcChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ringtoneChannel, null);
  });

  setUp(() {
    mockContactsRepo = _MockContactsRepository();
    mockCallsRepo = _MockCallsRepository();
    mockSignaling = _MockSignalingService();
    mockWebSocket = _MockWebSocketService();

    invitationController = StreamController<WebRTCCallInvitation>.broadcast();
    acceptController = StreamController<Map<String, dynamic>>.broadcast();
    endController = StreamController<Map<String, dynamic>>.broadcast();
    sdpController = StreamController<Map<String, dynamic>>.broadcast();
    iceController = StreamController<Map<String, dynamic>>.broadcast();
    inviteAckController = StreamController<Map<String, dynamic>>.broadcast();

    when(() => mockContactsRepo.contactsList())
        .thenAnswer((_) async => const Right([friendWithEmptyFullName]));
    when(() => mockContactsRepo.getFriendRequests())
        .thenAnswer((_) async => const Right(<User>[]));
    when(() => mockCallsRepo.getCallHistory())
        .thenAnswer((_) async => const Right(<CallLog>[]));
    when(
      () => mockCallsRepo.initiateCall(
        peerId: any(named: 'peerId'),
        isVideo: any(named: 'isVideo'),
        channelId: any(named: 'channelId'),
      ),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => mockCallsRepo.endCall(
        callId: any(named: 'callId'),
        recipientId: any(named: 'recipientId'),
      ),
    ).thenAnswer((_) async => const Right(null));
    when(() => mockCallsRepo.watchActiveCallSession())
        .thenAnswer((_) => const Stream.empty());

    when(() => mockSignaling.invitationStream)
        .thenAnswer((_) => invitationController.stream);
    when(() => mockSignaling.acceptStream)
        .thenAnswer((_) => acceptController.stream);
    when(() => mockSignaling.endStream).thenAnswer((_) => endController.stream);
    when(() => mockSignaling.sdpStream).thenAnswer((_) => sdpController.stream);
    when(() => mockSignaling.iceStream).thenAnswer((_) => iceController.stream);
    when(() => mockSignaling.inviteAckStream)
        .thenAnswer((_) => inviteAckController.stream);
    when(() => mockWebSocket.connect()).thenAnswer((_) async {});
    when(() => mockWebSocket.disconnect()).thenReturn(null);
  });

  tearDown(() async {
    await invitationController.close();
    await acceptController.close();
    await endController.close();
    await sdpController.close();
    await iceController.close();
    await inviteAckController.close();
  });

  List<Override> buildBaseOverrides({
    List<CallLog> callLogs = const [],
  }) {
    when(() => mockCallsRepo.getCallHistory())
        .thenAnswer((_) async => Right(callLogs));

    final contactsNotifier = ContactsNotifier(
      getContactsUseCase: GetContactsUseCase(repository: mockContactsRepo),
      searchUserUseCase: SearchUserUseCase(repository: mockContactsRepo),
      deleteFriendUseCase: DeleteFriendUseCase(repository: mockContactsRepo),
    );
    final friendRequestNotifier = FriendRequestNotifier(
      getFriendRequestUseCase:
          GetFriendRequestsUseCase(repository: mockContactsRepo),
      sendFriendRequestUseCase:
          SendFriendRequestUseCase(repository: mockContactsRepo),
      acceptFriendRequestUseCase:
          AcceptFriendRequestUseCase(repository: mockContactsRepo),
      rejectFriendRequestUseCase:
          RejectFriendRequestUseCase(repository: mockContactsRepo),
    );
    final callHistoryNotifier = CallHistoryNotifier(
      GetCallHistoryUseCase(mockCallsRepo),
    );
    final activeCallNotifier = ActiveCallNotifier(
      initiateCallUseCase: InitiateCallUseCase(mockCallsRepo),
      acceptCallUseCase: AcceptCallUseCase(mockCallsRepo),
      endCallUseCase: EndCallUseCase(mockCallsRepo),
      sendSdpUseCase: SendSdpUseSase(repository: mockCallsRepo),
    );
    final presenceNotifier = PresenceNotifier();

    return [
      settingsNotifierProvider.overrideWith(
        (_) => _FakeSettingsNotifier(testSettings),
      ),
      contactsProvider.overrideWith((_) => contactsNotifier),
      friendRequestProvider.overrideWith((_) => friendRequestNotifier),
      callHistoryProvider.overrideWith((_) => callHistoryNotifier),
      activeCallProvider.overrideWith((_) => activeCallNotifier),
      presenceProvider.overrideWith((_) => presenceNotifier),
      webrtcSignalingServiceProvider.overrideWithValue(mockSignaling),
      webSocketServiceProvider.overrideWithValue(mockWebSocket),
      webSocketSyncCoordinatorProvider.overrideWith((_) {}),
      incomingCallProvider.overrideWith((_) => invitationController.stream),
    ];
  }

  Widget buildApp(Widget home, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  group('Contacts calling flows', () {
    testWidgets(
      'tapping voice call on FriendScreen launches CallsScreen even when '
      'friend fullName is empty, and cancelling pops back',
      (tester) async {
        final overrides = buildBaseOverrides();
        await tester.pumpWidget(
          buildApp(const Scaffold(body: FriendScreen()), overrides),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Voice call'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CallsScreen), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(CallsScreen),
            matching: find.text('alice'),
          ),
          findsOneWidget,
        );
        verify(
          () => mockCallsRepo.initiateCall(
            peerId: 'friend-1',
            isVideo: false,
            channelId: any(named: 'channelId'),
          ),
        ).called(1);

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();

        expect(find.byType(CallsScreen), findsNothing);
        expect(find.byType(FriendScreen), findsOneWidget);
      },
    );

    testWidgets(
      'tapping call button on HistoryCard in HistoryScreen launches '
      'CallsScreen for outgoing call logs',
      (tester) async {
        final log = CallLog(
          id: 'call-1',
          hostId: 'me-1',
          username: 'alice',
          channelId: 'room-1',
          isVideo: true,
          status: 'ended',
          createdAt: DateTime.now(),
        );
        final overrides = buildBaseOverrides(callLogs: [log]);

        await tester.pumpWidget(
          buildApp(const Scaffold(body: HistoryScreen()), overrides),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HistoryCard), findsOneWidget);

        await tester.tap(find.byTooltip('Video call'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CallsScreen), findsOneWidget);
        verify(
          () => mockCallsRepo.initiateCall(
            peerId: 'friend-1',
            isVideo: true,
            channelId: any(named: 'channelId'),
          ),
        ).called(1);

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();
        expect(find.byType(CallsScreen), findsNothing);
      },
    );

    testWidgets(
      'MainShellScreen opens CallsScreen ringing UI on incoming call',
      (tester) async {
        final overrides = [
          ...buildBaseOverrides(),
          notificationsProvider.overrideWith(
            (_) => _FakeNotificationsNotifier(),
          ),
          shellIndexProvider.overrideWith((_) => 2),
        ];

        await tester.pumpWidget(
          buildApp(
            const MainShellScreen(
              pages: [
                SizedBox.shrink(),
                SizedBox.shrink(),
                ContactsScreen(),
                SizedBox.shrink(),
                SizedBox.shrink(),
              ],
            ),
            overrides,
          ),
        );
        await tester.pumpAndSettle();

        expect(CallsScreen.isCurrentlyOpen, isFalse);

        invitationController.add(
          WebRTCCallInvitation(
            callId: 'srv-call-99',
            senderId: 'friend-1',
            conversationId: null,
            channelId: 'room-99',
            isVideo: false,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CallsScreen), findsOneWidget);
        expect(find.text('alice'), findsAtLeastNWidgets(1));
        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();

        expect(find.byType(CallsScreen), findsNothing);
        expect(find.byType(ContactsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'CallsScreen shows error and pops back when call initiation fails',
      (tester) async {
        final overrides = buildBaseOverrides();
        when(
          () => mockCallsRepo.initiateCall(
            peerId: any(named: 'peerId'),
            isVideo: any(named: 'isVideo'),
            channelId: any(named: 'channelId'),
          ),
        ).thenAnswer(
          (_) async => const Left(
            NetworkFailure('Unable to connect to signaling server.'),
          ),
        );

        await tester.pumpWidget(
          buildApp(const Scaffold(body: FriendScreen()), overrides),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Voice call'));
        await tester.pumpAndSettle();

        expect(find.byType(CallsScreen), findsNothing);
        expect(find.byType(FriendScreen), findsOneWidget);
        expect(
          find.text('Unable to connect to signaling server.'),
          findsOneWidget,
        );
      },
    );
  });
}
