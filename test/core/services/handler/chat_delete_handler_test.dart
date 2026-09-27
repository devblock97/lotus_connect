import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/services/websocket/handler/chat_delete_handler.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';

class MockChatCoreLocalDataSource extends Mock
    implements ChatCoreLocalDataSource {}

void main() {
  late MockChatCoreLocalDataSource mockLocalDataSource;
  late ChatDeleteHandler handler;

  setUp(() {
    mockLocalDataSource = MockChatCoreLocalDataSource();
    handler = ChatDeleteHandler(mockLocalDataSource);
  });

  group('ChatDeleteHandler', () {
    group('supportedEvents', () {
      test('contains only "chat:delete"', () {
        expect(handler.supportedEvents, equals(['chat:delete']));
      });

      test('supports "chat:delete"', () {
        expect(handler.supportedEvents, contains('chat:delete'));
      });
    });

    group('handle', () {
      test(
          'deletes message when valid messageId '
          'is provided in payload', () async {
        const messageId = 'msg_12345';
        final payload = {'messageId': messageId};
        when(() => mockLocalDataSource.deleteMessage(messageId))
            .thenAnswer((_) async {});

        await handler.handle('chat:delete', payload);

        verify(() => mockLocalDataSource.deleteMessage(messageId)).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('does not delete message when messageId is empty string', () async {
        final payload = {'messageId': ''};

        await handler.handle('chat:delete', payload);

        verifyNever(() => mockLocalDataSource.deleteMessage(any()));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('does not delete message when messageId is null', () async {
        final payload = {'messageId': null};

        await handler.handle('chat:delete', payload);

        verifyNever(() => mockLocalDataSource.deleteMessage(any()));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test(
          'does not delete message when messageId key '
          'is absent in payload', () async {
        final payload = <String, dynamic>{};

        await handler.handle('chat:delete', payload);

        verifyNever(() => mockLocalDataSource.deleteMessage(any()));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('propagates exception when deleteMessage throws', () async {
        const messageId = 'msg_err';
        final payload = {'messageId': messageId};
        final exception = Exception('Failed to delete message from database');
        when(() => mockLocalDataSource.deleteMessage(messageId))
            .thenThrow(exception);

        expect(
          () => handler.handle('chat:delete', payload),
          throwsA(same(exception)),
        );

        verify(() => mockLocalDataSource.deleteMessage(messageId)).called(1);
      });
    });

    group('chatDeleteHandler provider', () {
      test(
          'instantiates ChatDeleteHandler with injected '
          'ChatCoreLocalDataSource', () {
        final container = ProviderContainer(
          overrides: [
            chatCoreLocalDataSourceProvider
                .overrideWithValue(mockLocalDataSource),
          ],
        );
        addTearDown(container.dispose);

        final providerHandler = container.read(chatDeleteHandler);

        expect(providerHandler, isA<ChatDeleteHandler>());
        expect(providerHandler.supportedEvents, contains('chat:delete'));
      });
    });
  });
}
