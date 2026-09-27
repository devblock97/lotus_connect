import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_edit_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:mocktail/mocktail.dart';

class MockChatCoreLocalDataSource extends Mock
    implements ChatCoreLocalDataSource {}

class FakeConversation extends Fake implements Conversation {}

class FakeMessage extends Fake implements Message {}

void main() {
  late MockChatCoreLocalDataSource mockChatCoreLocalDataSource;
  late ChatEditHandler handler;
  const currentUserId = 'user_me_123';
  final sampleMessage = Message(
    id: 'msg_12345',
    conversationId: 'conv_001',
    role: MessageRole.user,
    content: 'Original message text',
    timestamp: DateTime(2026, 9, 27, 11, 11),
  );

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
    mockChatCoreLocalDataSource = MockChatCoreLocalDataSource();
    handler = ChatEditHandler(mockChatCoreLocalDataSource);
  });

  group('ChatEditHandler', () {
    group('supportedEvents', () {
      test('contains only "chat:edit"', () {
        expect(handler.supportedEvents, equals(['chat:edit']));
      });

      test('supports "chat:edit"', () {
        expect(handler.supportedEvents, contains('chat:edit'));
      });
    });

    group('handle', () {
      test(
          'edit message when valid messageId and content'
          ' are provided in payload', () async {
        const messageId = 'msg_12345';
        const newContent = 'Updated message text';
        final payload = {
          'messageId': messageId,
          'content': newContent,
        };

        when(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .thenAnswer((_) async => sampleMessage);
        when(() => mockChatCoreLocalDataSource.saveMessage(any()))
            .thenAnswer((_) async {});

        await handler.handle('chat:edit', payload);

        verify(
          () => mockChatCoreLocalDataSource.getMessage(messageId),
        ).called(1);
        final captured = verify(
          () => mockChatCoreLocalDataSource.saveMessage(captureAny()),
        ).captured.single as Message;

        expect(captured.id, sampleMessage.id);
        expect(captured.conversationId, sampleMessage.conversationId);
        expect(captured.role, sampleMessage.role);
        expect(captured.content, newContent);
        expect(captured.timestamp, sampleMessage.timestamp);
        verifyNoMoreInteractions(mockChatCoreLocalDataSource);
      });

      test(
          'does not save message when message does not exist '
          'in local data source', () async {
        const messageId = 'mgs_non_existent';
        final payload = {
          'messageId': messageId,
          'content': 'Some content',
        };

        when(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .thenAnswer((_) async => null);

        await handler.handle('chat:edit', payload);

        verify(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .called(1);
        verifyNever(() => mockChatCoreLocalDataSource.saveMessage(any()));
        verifyNoMoreInteractions(mockChatCoreLocalDataSource);
      });

      test('does not save message when messageId is empty string', () async {
        final payload = {
          'messageId': '',
          'content': 'New content',
        };

        when(() => mockChatCoreLocalDataSource.getMessage(''))
            .thenAnswer((_) async => null);

        await handler.handle('chat:edit', payload);

        verify(() => mockChatCoreLocalDataSource.getMessage('')).called(1);
        verifyNever(() => mockChatCoreLocalDataSource.saveMessage(any()));
        verifyNoMoreInteractions(mockChatCoreLocalDataSource);
      });

      test(
          'does not save message when messageId key '
          'is absent in payload', () async {
        final payload = <String, dynamic>{
          'content': 'New content',
        };

        when(() => mockChatCoreLocalDataSource.getMessage(''))
            .thenAnswer((_) async => null);

        await handler.handle('chat:edit', payload);

        verify(() => mockChatCoreLocalDataSource.getMessage('')).called(1);
        verifyNever(() => mockChatCoreLocalDataSource.saveMessage(any()));
        verifyNoMoreInteractions(mockChatCoreLocalDataSource);
      });

      test(
          'defaults content to empty string when content '
          'is null in payload', () async {
        const messageId = 'mgs_12345';
        final payload = {
          'messageId': messageId,
          'content': null,
        };

        when(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .thenAnswer((_) async => sampleMessage);

        when(() => mockChatCoreLocalDataSource.saveMessage(any()))
            .thenAnswer((_) async {});

        await handler.handle('chat:edit', payload);

        verify(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .called(1);
        final captured = verify(
          () => mockChatCoreLocalDataSource.saveMessage(captureAny()),
        ).captured.single as Message;

        expect(captured.content, '');
        verifyNoMoreInteractions(mockChatCoreLocalDataSource);
      });

      test('propagates exception when getMessage throws', () async {
        const messageId = 'msg_err';
        final payload = {
          'messageId': messageId,
          'content': 'Content',
        };

        final exception = Exception('Database write failure');

        when(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .thenAnswer((_) async => sampleMessage);
        when(() => mockChatCoreLocalDataSource.saveMessage(any()))
            .thenThrow(exception);

        await expectLater(
          () => handler.handle('chat:edit', payload),
          throwsA(exception),
        );

        verify(() => mockChatCoreLocalDataSource.getMessage(messageId))
            .called(1);
        verify(() => mockChatCoreLocalDataSource.saveMessage(any())).called(1);
      });
    });
  });

  group('chatEditHandler provider', () {
    test(
        'instantiates ChatEditHandler with injected '
        'ChatCoreLocalDataSource', () {
      final container = ProviderContainer(
        overrides: [
          chatCoreLocalDataSourceProvider
              .overrideWithValue(mockChatCoreLocalDataSource),
        ],
      );

      addTearDown(container.dispose);

      final providerHandler = container.read(chatEditHandler);

      expect(providerHandler, isA<ChatEditHandler>());
      expect(providerHandler.supportedEvents, contains('chat:edit'));
    });
  });
}
