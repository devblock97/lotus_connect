import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/application/call_history_notifier.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/usecases/get_call_history_usecase.dart';
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
import 'package:lotus_connect/features/contacts/presentation/views/request_friend_screen.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/contact_card.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/history_card.dart';
import 'package:lotus_connect/features/contacts/presentation/widgets/request_card.dart';
import 'package:lotus_connect/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockContactsRepository extends Mock implements ContactsRepository {}

class _MockGetCallHistoryUseCase extends Mock
    implements GetCallHistoryUseCase {}

void main() {
  late _MockContactsRepository mockContactsRepo;
  late _MockGetCallHistoryUseCase mockGetCallHistoryUseCase;

  const sampleUser1 = User(
    id: 'user-1',
    username: 'alice',
    fullName: 'Alice Wonder',
    email: 'alice@lotus.io',
  );

  const sampleUser2 = User(
    id: 'user-2',
    username: 'bob',
    fullName: 'Bob Builder',
    email: 'bob@lotus.io',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockContactsRepo = _MockContactsRepository();
    mockGetCallHistoryUseCase = _MockGetCallHistoryUseCase();

    when(() => mockContactsRepo.contactsList())
        .thenAnswer((_) async => const Right([sampleUser1]));
    when(() => mockContactsRepo.getFriendRequests())
        .thenAnswer((_) async => const Right([sampleUser2]));
    when(() => mockContactsRepo.searchUsers(any()))
        .thenAnswer((_) async => const Right([sampleUser2]));
    when(() => mockGetCallHistoryUseCase.call(any()))
        .thenAnswer((_) async => const Right(<CallLog>[]));
  });

  Widget buildLocalizedWidget({
    required Widget child,
    Locale locale = const Locale('en'),
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('ContactsScreen Localization', () {
    testWidgets('renders tabs and appbar titles in English', (tester) async {
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

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const ContactsScreen(),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
            friendRequestProvider.overrideWith((ref) => friendRequestNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders tabs and appbar titles in Vietnamese', (tester) async {
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

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const ContactsScreen(),
          locale: const Locale('vi'),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
            friendRequestProvider.overrideWith((ref) => friendRequestNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Danh bạ'), findsOneWidget);
      expect(find.text('Bạn bè'), findsOneWidget);
      expect(find.text('Lịch sử'), findsOneWidget);
      expect(find.text('Chờ duyệt'), findsOneWidget);
    });
  });

  group('FriendScreen Localization', () {
    testWidgets('renders search hint and section headers in English',
        (tester) async {
      final contactsNotifier = ContactsNotifier(
        getContactsUseCase: GetContactsUseCase(repository: mockContactsRepo),
        searchUserUseCase: SearchUserUseCase(repository: mockContactsRepo),
        deleteFriendUseCase: DeleteFriendUseCase(repository: mockContactsRepo),
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const Scaffold(body: FriendScreen()),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search friends...'), findsOneWidget);
      expect(find.text('ALL FRIENDS'), findsOneWidget);
      expect(find.text('Alice Wonder'), findsOneWidget);
    });

    testWidgets('renders search hint and section headers in Vietnamese',
        (tester) async {
      final contactsNotifier = ContactsNotifier(
        getContactsUseCase: GetContactsUseCase(repository: mockContactsRepo),
        searchUserUseCase: SearchUserUseCase(repository: mockContactsRepo),
        deleteFriendUseCase: DeleteFriendUseCase(repository: mockContactsRepo),
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const Scaffold(body: FriendScreen()),
          locale: const Locale('vi'),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm kiếm bạn bè...'), findsOneWidget);
      expect(find.text('TẤT CẢ BẠN BÈ'), findsOneWidget);
      expect(find.text('Alice Wonder'), findsOneWidget);
    });

    testWidgets('shows empty state localized message when no contacts exist',
        (tester) async {
      when(() => mockContactsRepo.contactsList())
          .thenAnswer((_) async => const Right(<User>[]));

      final contactsNotifier = ContactsNotifier(
        getContactsUseCase: GetContactsUseCase(repository: mockContactsRepo),
        searchUserUseCase: SearchUserUseCase(repository: mockContactsRepo),
        deleteFriendUseCase: DeleteFriendUseCase(repository: mockContactsRepo),
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const Scaffold(body: FriendScreen()),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Contacts found'), findsOneWidget);
      expect(
        find.text('Send friend requests to start chatting and calling.'),
        findsOneWidget,
      );
      expect(find.text('Add Friend'), findsOneWidget);
    });
  });

  group('ContactCard Localization', () {
    testWidgets('renders tooltips and localized presence for online contact',
        (tester) async {
      final presenceNotifier = PresenceNotifier();
      presenceNotifier.updatePresence('user-1', true, DateTime.now());

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: ContactCard(
              friend: sampleUser1,
              startChat: () {},
              voiceCall: () {},
              videoCall: () {},
              onDelete: () {},
              onProfileTap: () {},
            ),
          ),
          overrides: [
            presenceProvider.overrideWith((ref) => presenceNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
      expect(find.byTooltip('Chat'), findsOneWidget);
      expect(find.byTooltip('Voice call'), findsOneWidget);
      expect(find.byTooltip('Video call'), findsOneWidget);
      expect(find.byTooltip('More options'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();

      expect(find.text('View Profile'), findsOneWidget);
      expect(find.text('Unfriend'), findsOneWidget);
    });

    testWidgets('renders Vietnamese translations for presence and popup menu',
        (tester) async {
      final presenceNotifier = PresenceNotifier();
      presenceNotifier.updatePresence('user-1', true, DateTime.now());

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: ContactCard(
              friend: sampleUser1,
              startChat: () {},
              voiceCall: () {},
              videoCall: () {},
              onDelete: () {},
              onProfileTap: () {},
            ),
          ),
          locale: const Locale('vi'),
          overrides: [
            presenceProvider.overrideWith((ref) => presenceNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trực tuyến'), findsOneWidget);
      expect(find.byTooltip('Trò chuyện'), findsOneWidget);
      expect(find.byTooltip('Cuộc gọi thoại'), findsOneWidget);
      expect(find.byTooltip('Cuộc gọi video'), findsOneWidget);
      expect(find.byTooltip('Tùy chọn khác'), findsOneWidget);

      await tester.tap(find.byTooltip('Tùy chọn khác'));
      await tester.pumpAndSettle();

      expect(find.text('Xem trang cá nhân'), findsOneWidget);
      expect(find.text('Hủy kết bạn'), findsOneWidget);
    });

    testWidgets('renders relative time for offline presence', (tester) async {
      final presenceNotifier = PresenceNotifier();
      final tenMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 10));
      presenceNotifier.updatePresence('user-1', false, tenMinutesAgo);

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: ContactCard(
              friend: sampleUser1,
              startChat: () {},
            ),
          ),
          overrides: [
            presenceProvider.overrideWith((ref) => presenceNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('10m ago'), findsOneWidget);
    });
  });

  group('HistoryScreen and HistoryCard Localization', () {
    testWidgets('shows empty state when no call history exists in Vietnamese',
        (tester) async {
      final contactsNotifier = ContactsNotifier(
        getContactsUseCase: GetContactsUseCase(repository: mockContactsRepo),
        searchUserUseCase: SearchUserUseCase(repository: mockContactsRepo),
        deleteFriendUseCase: DeleteFriendUseCase(repository: mockContactsRepo),
      );
      final callHistoryNotifier = CallHistoryNotifier(
        mockGetCallHistoryUseCase,
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const Scaffold(body: HistoryScreen()),
          locale: const Locale('vi'),
          overrides: [
            contactsProvider.overrideWith((ref) => contactsNotifier),
            callHistoryProvider.overrideWith((ref) => callHistoryNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không có lịch sử cuộc gọi'), findsOneWidget);
    });

    testWidgets('renders localized call log details and duration',
        (tester) async {
      final now = DateTime.now();
      final sampleLog = CallLog(
        id: 'call-1',
        hostId: 'other-user',
        hostName: 'Alice Wonder',
        channelId: 'ch-1',
        isVideo: true,
        status: 'accepted',
        createdAt: now,
        endedAt: now.add(const Duration(seconds: 90)),
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: HistoryCard(
              log: sampleLog,
              friends: const [sampleUser1],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice Wonder'), findsOneWidget);
      expect(find.text('Video call'), findsOneWidget);
      expect(find.text('1m 30s'), findsOneWidget);
    });

    testWidgets('renders fallback localized user with truncated ID',
        (tester) async {
      final now = DateTime.now();
      final sampleLog = CallLog(
        id: 'call-2',
        hostId: '123456789-abcdef',
        channelId: 'ch-2',
        isVideo: false,
        status: 'missed',
        createdAt: now,
      );

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: HistoryCard(
              log: sampleLog,
            ),
          ),
          locale: const Locale('vi'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Người dùng 12345678'), findsOneWidget);
      expect(find.text('Cuộc gọi thoại'), findsOneWidget);
      expect(find.text('Nhỡ'), findsOneWidget);
    });
  });

  group('AllFriendRequestsScreen and RequestCard Localization', () {
    testWidgets('renders empty state in English', (tester) async {
      when(() => mockContactsRepo.getFriendRequests())
          .thenAnswer((_) async => const Right(<User>[]));

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

      await tester.pumpWidget(
        buildLocalizedWidget(
          child: const Scaffold(body: AllFriendRequestsScreen()),
          overrides: [
            friendRequestProvider.overrideWith((ref) => friendRequestNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No pending requests'), findsOneWidget);
    });

    testWidgets('renders RequestCard tooltips and user information',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedWidget(
          child: Scaffold(
            body: RequestCard(
              user: sampleUser2,
              startChat: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bob Builder'), findsOneWidget);
      expect(find.text('@bob'), findsOneWidget);
      expect(find.byTooltip('Chat'), findsOneWidget);
      expect(find.byTooltip('Accept'), findsOneWidget);
      expect(find.byTooltip('Reject'), findsOneWidget);
    });
  });
}
