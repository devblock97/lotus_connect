import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_message_handler.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatCoreLocalDataSource extends Mock
    implements ChatCoreLocalDataSource {}

class FakeConversation extends Fake implements Conversation {}

class FakeMessage extends Fake implements Message {}

void main() {
  late MockChatCoreLocalDataSource dataSource;
  late ChatMessageWebSocketHandler handler;
  const currentUserId = 'user_me_123';

  setUpAll(() {
    registerFallbackValue(FakeConversation());
    registerFallbackValue(
      Message(
        id: 'fallback_id',
        conversationId: 'fallback_conv',
        role: MessageRole.user,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
  });

  setUp(() {
    dataSource = MockChatCoreLocalDataSource();
    handler = ChatMessageWebSocketHandler(
      localDataSource: dataSource,
      currentUserIdGetter: () => currentUserId,
    );
  });

  group('ChatMessageWebSocketHandler', () {
    test('supportedEvents contains "chat:message"', () {
      expect(handler.supportedEvents, contains('chat:message'));
    });

    test(
        'ignores incoming message if senderId matches '
        'currentUserId', () async {
      final payload = {
        'id': 'msg_001',
        'conversationId': 'conv_001',
        'senderId': currentUserId,
        'content': 'Hello self',
      };

      await handler.handle('chat:message', payload);

      verifyNever(() => dataSource.getConversations());
      verifyNever(() => dataSource.saveMessage(any()));
    });

    test(
        'creates conversation and saves message when conversation '
        'does not exist', () async {
      when(() => dataSource.getConversations()).thenAnswer((_) async => []);

      when(
        () => dataSource.createConversation(
          id: any(named: 'id'),
          title: any(named: 'title'),
          isUserToUser: any(named: 'isUserToUser'),
          peerId: any(named: 'peerId'),
        ),
      ).thenAnswer((_) async => FakeConversation());

      when(() => dataSource.saveMessage(any())).thenAnswer((_) async {});

      final payload = {
        'id': 'msg_100',
        'conversationId': 'conv_100',
        'senderId': 'peer_9999999',
        'content': 'Hello from peer',
        'sender': {
          'fullName': 'Alice Wonderland',
        },
      };

      await handler.handle('chat:message', payload);

      verify(
        () => dataSource.createConversation(
          id: 'conv_100',
          title: 'Alice Wonderland',
          isUserToUser: true,
          peerId: 'peer_9999999',
        ),
      ).called(1);

      final captured = verify(() => dataSource.saveMessage(captureAny()))
          .captured
          .single as Message;

      expect(captured.id, 'msg_100');
      expect(captured.conversationId, 'conv_100');
      expect(captured.content, 'Hello from peer');
      expect(captured.role, MessageRole.assistant);
    });
  });
}
