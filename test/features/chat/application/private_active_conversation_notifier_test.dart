import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/features/chat/application/private_active_conversation_notifier.dart';
import 'package:lotus_connect/features/chat/application/private_chat_providers.dart';
import 'package:lotus_connect/features/chat/application/private_conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockPrivateChatRepository extends Mock implements PrivateChatRepository {}

class MockChatCoreRepository extends Mock implements ChatCoreRepository {}

class MockSettingsNotifier extends StateNotifier<AppSettings>
    with Mock
    implements SettingsNotifier {
  MockSettingsNotifier(super.state);
}

class MockPrivateConversationListNotifier
    extends StateNotifier<PrivateConversationListState>
    with Mock
    implements PrivateConversationListNotifier {
  MockPrivateConversationListNotifier(super.state);
}

void main() {
  late MockPrivateChatRepository mockPrivateChatRepo;
  late MockChatCoreRepository mockChatCoreRepo;
  late MockSettingsNotifier mockSettingsNotifier;
  late MockPrivateConversationListNotifier mockListNotifier;

  setUpAll(() {
    registerFallbackValue(
      Message(
        id: '',
        conversationId: '',
        role: MessageRole.user,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockPrivateChatRepo = MockPrivateChatRepository();
    mockChatCoreRepo = MockChatCoreRepository();

    mockSettingsNotifier = MockSettingsNotifier(
      const AppSettings(userId: 'test_user_id'),
    );
    mockListNotifier = MockPrivateConversationListNotifier(
      const PrivateConversationListState(
        selectedConversationId: 'test_conv_id',
      ),
    );
  });

  test(
      'should reconcile complete history when remote messages count is less than 100',
      () async {
    final timestamp1 = DateTime.now().subtract(const Duration(minutes: 5));
    final timestamp2 = DateTime.now().subtract(const Duration(minutes: 3));
    final timestamp3 = DateTime.now().subtract(const Duration(minutes: 1));
    final timestamp0 = DateTime.now().subtract(const Duration(minutes: 10));

    // Remote messages: only msg1 and msg3 are on server (msg2 and msg0 were deleted/absent)
    // Since count is 2 (less than 100), we sync the entire history.
    final remoteMessages = [
      Message(
        id: '00000000-0000-0000-0000-000000000001',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Remote 1',
        timestamp: timestamp1,
      ),
      Message(
        id: '00000000-0000-0000-0000-000000000003',
        conversationId: 'test_conv_id',
        role: MessageRole.assistant,
        content: 'Remote 3',
        timestamp: timestamp3,
      ),
    ];

    final localMessages = [
      Message(
        id: '00000000-0000-0000-0000-000000000000',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Local 0 (deleted on server)',
        timestamp: timestamp0,
      ),
      Message(
        id: '00000000-0000-0000-0000-000000000001',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Local 1',
        timestamp: timestamp1,
      ),
      Message(
        id: '00000000-0000-0000-0000-000000000002',
        conversationId: 'test_conv_id',
        role: MessageRole.assistant,
        content: 'Local 2 (deleted on server)',
        timestamp: timestamp2,
      ),
      Message(
        id: '00000000-0000-0000-0000-000000000003',
        conversationId: 'test_conv_id',
        role: MessageRole.assistant,
        content: 'Local 3',
        timestamp: timestamp3,
      ),
      Message(
        id: 'legacy-timestamp-id-12345',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Legacy local only',
        timestamp: timestamp2,
      ),
    ];

    when(() => mockChatCoreRepo.watchMessages('test_conv_id'))
        .thenAnswer((_) => Stream.value(Right(localMessages)));

    when(
      () => mockPrivateChatRepo.fetchRemoteMessages(
        conversationId: 'test_conv_id',
        currentUserId: 'test_user_id',
      ),
    ).thenAnswer((_) async => Right(remoteMessages));

    for (final msg in remoteMessages) {
      when(() => mockChatCoreRepo.saveMessage(msg))
          .thenAnswer((_) async => const Right(null));
    }

    when(() => mockChatCoreRepo.getMessages('test_conv_id'))
        .thenAnswer((_) async => Right(localMessages));

    when(() => mockChatCoreRepo.deleteMessage(any())).thenAnswer(
      (_) async => const Right(null),
    );

    final container = ProviderContainer(
      overrides: [
        privateChatRepositoryProvider.overrideWithValue(mockPrivateChatRepo),
        chatCoreRepositoryProvider.overrideWithValue(mockChatCoreRepo),
        settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        privateConversationListProvider.overrideWith((ref) => mockListNotifier),
      ],
    );

    addTearDown(container.dispose);

    container.read(privateActiveConversationProvider.notifier);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Verify all remote messages were saved
    for (final msg in remoteMessages) {
      verify(() => mockChatCoreRepo.saveMessage(msg)).called(1);
    }

    // Verify msg2 and msg0 (UUIDs missing from remote) were deleted
    verify(
      () => mockChatCoreRepo
          .deleteMessage('00000000-0000-0000-0000-000000000002'),
    ).called(1);
    verify(
      () => mockChatCoreRepo
          .deleteMessage('00000000-0000-0000-0000-000000000000'),
    ).called(1);

    // Verify legacy message (not a UUID) was NOT deleted
    verifyNever(
      () => mockChatCoreRepo.deleteMessage('legacy-timestamp-id-12345'),
    );
  });

  test(
      'should reconcile within window when remote messages count is 100 or more (partial history)',
      () async {
    final timestampMin = DateTime.now().subtract(const Duration(minutes: 100));
    final timestamp0 =
        DateTime.now().subtract(const Duration(minutes: 105)); // Outside window
    final timestamp2 = DateTime.now().subtract(
      const Duration(minutes: 50),
    ); // Inside window, deleted on remote

    // Generate 100 remote messages
    final remoteMessages = List.generate(100, (i) {
      final t = DateTime.now().subtract(Duration(minutes: i));
      return Message(
        id: '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
        conversationId: 'test_conv_id',
        role: MessageRole.assistant,
        content: 'Remote message $i',
        timestamp: t,
      );
    });

    // Make the oldest one (index 99) have timestampMin
    remoteMessages[99] = Message(
      id: '00000000-0000-0000-0000-000000000099',
      conversationId: 'test_conv_id',
      role: MessageRole.assistant,
      content: 'Remote message 99',
      timestamp: timestampMin,
    );

    final localMessages = [
      Message(
        id: '00000000-0000-0000-0000-111111111111',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Old local message (outside window)',
        timestamp: timestamp0,
      ),
      Message(
        id: '00000000-0000-0000-0000-222222222222',
        conversationId: 'test_conv_id',
        role: MessageRole.assistant,
        content: 'Local 2 (deleted on server)',
        timestamp: timestamp2,
      ),
      Message(
        id: 'legacy-timestamp-id-12345',
        conversationId: 'test_conv_id',
        role: MessageRole.user,
        content: 'Legacy local only',
        timestamp: timestamp2,
      ),
      ...remoteMessages,
    ];

    when(() => mockChatCoreRepo.watchMessages('test_conv_id'))
        .thenAnswer((_) => Stream.value(Right(localMessages)));

    when(
      () => mockPrivateChatRepo.fetchRemoteMessages(
        conversationId: 'test_conv_id',
        currentUserId: 'test_user_id',
      ),
    ).thenAnswer((_) async => Right(remoteMessages));

    for (final msg in remoteMessages) {
      when(() => mockChatCoreRepo.saveMessage(msg))
          .thenAnswer((_) async => const Right(null));
    }

    when(() => mockChatCoreRepo.getMessages('test_conv_id'))
        .thenAnswer((_) async => Right(localMessages));

    when(() => mockChatCoreRepo.deleteMessage(any())).thenAnswer(
      (_) async => const Right(null),
    );

    final container = ProviderContainer(
      overrides: [
        privateChatRepositoryProvider.overrideWithValue(mockPrivateChatRepo),
        chatCoreRepositoryProvider.overrideWithValue(mockChatCoreRepo),
        settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        privateConversationListProvider.overrideWith((ref) => mockListNotifier),
      ],
    );

    addTearDown(container.dispose);

    container.read(privateActiveConversationProvider.notifier);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Verify msg deleted on server was deleted locally (inside window)
    verify(
      () => mockChatCoreRepo
          .deleteMessage('00000000-0000-0000-0000-222222222222'),
    ).called(1);

    // Verify msg older than minTimestamp was NOT deleted (outside window)
    verifyNever(
      () => mockChatCoreRepo
          .deleteMessage('00000000-0000-0000-0000-111111111111'),
    );

    // Verify legacy message was NOT deleted
    verifyNever(
      () => mockChatCoreRepo.deleteMessage('legacy-timestamp-id-12345'),
    );
  });

  test(
      'should handle reply to message state, send it, and clear the reply state',
      () async {
    final parentMessage = Message(
      id: 'parent_id_123',
      conversationId: 'test_conv_id',
      role: MessageRole.assistant,
      content: 'Hello, parent message',
      timestamp: DateTime.now(),
    );

    when(() => mockChatCoreRepo.watchMessages('test_conv_id'))
        .thenAnswer((_) => Stream.value(const Right([])));

    final container = ProviderContainer(
      overrides: [
        privateChatRepositoryProvider.overrideWithValue(mockPrivateChatRepo),
        chatCoreRepositoryProvider.overrideWithValue(mockChatCoreRepo),
        settingsProvider.overrideWith((ref) => mockSettingsNotifier),
        privateConversationListProvider.overrideWith((ref) => mockListNotifier),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(privateActiveConversationProvider.notifier);

    // Initial state: replyingToMessage is null
    expect(
      container.read(privateActiveConversationProvider).replyingToMessage,
      isNull,
    );

    // 1. Set reply message
    notifier.setReplyingToMessage(parentMessage);
    expect(
      container.read(privateActiveConversationProvider).replyingToMessage,
      parentMessage,
    );

    // 2. Cancel reply
    notifier.cancelReply();
    expect(
      container.read(privateActiveConversationProvider).replyingToMessage,
      isNull,
    );

    // 3. Set reply again and mock send message use case
    notifier.setReplyingToMessage(parentMessage);

    // We need to mock chat core repo save/delete calls for sending message
    when(() => mockChatCoreRepo.saveMessage(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockChatCoreRepo.saveDraftMessage(any(), any()))
        .thenAnswer((_) async => const Right(null));
    when(
      () => mockPrivateChatRepo.sendMessage(
        conversationId: 'test_conv_id',
        content: 'Reply content',
        replyToId: 'parent_id_123',
      ),
    ).thenAnswer(
      (_) async => Right(
        Message(
          id: 'new_msg_id',
          conversationId: 'test_conv_id',
          role: MessageRole.user,
          content: 'Reply content',
          timestamp: DateTime.now(),
          replyToId: 'parent_id_123',
        ),
      ),
    );
    when(() => mockChatCoreRepo.deleteMessage(any()))
        .thenAnswer((_) async => const Right(null));

    // Send the reply message
    await notifier.sendMessage('Reply content');

    // Verify reply state is cleared
    expect(
      container.read(privateActiveConversationProvider).replyingToMessage,
      isNull,
    );

    // Verify repository sendMessage call received correct replyToId
    verify(
      () => mockPrivateChatRepo.sendMessage(
        conversationId: 'test_conv_id',
        content: 'Reply content',
        replyToId: 'parent_id_123',
      ),
    ).called(1);
  });
}
