import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_dispatcher.dart';
import 'package:lotus_connect/core/services/websocket/websocket_event_handler.dart';
import 'package:mocktail/mocktail.dart';

class MockWebSocketEventHandler extends Mock implements WebSocketEventHandler {}

void main() {
  late MockWebSocketEventHandler mockMessageHandler;
  late MockWebSocketEventHandler mockTypingHandler;
  late WebSocketEventDispatcher dispatcher;

  setUp(() {
    mockMessageHandler = MockWebSocketEventHandler();
    mockTypingHandler = MockWebSocketEventHandler();

    when(() => mockMessageHandler.supportedEvents).thenReturn(['chat:message']);

    when(() => mockTypingHandler.supportedEvents).thenReturn(['typing']);

    dispatcher = WebSocketEventDispatcher([
      mockMessageHandler,
      mockTypingHandler,
    ]);
  });

  group('WebSocketEventDispatcher', () {
    test('routes "chat:message" frame to message handler', () async {
      when(() => mockMessageHandler.handle(any(), any()))
          .thenAnswer((_) async {});

      final frame = {
        'event': 'chat:message',
        'payload': {'content': 'Hello world'},
      };

      await dispatcher.dispatch(frame);

      verify(
        () => mockMessageHandler.handle(
          'chat:message',
          {'content': 'Hello world'},
        ),
      ).called(1);
      verifyNever(() => mockTypingHandler.handle(any(), any()));
    });

    test('ignores frames without "event" key without errors', () async {
      await dispatcher.dispatch(
        {
          'payload': <String, dynamic>{},
        },
      );

      verifyNever(() => mockMessageHandler.handle(any(), any()));
    });

    test('ignores unregistered events gracefully', () async {
      await dispatcher.dispatch({
        'event': 'unknown:event',
        'payload': {'data': 123},
      });

      verifyNever(() => mockMessageHandler.handle(any(), any()));
      verifyNever(() => mockTypingHandler.handle(any(), any()));
    });

    test(
        'catches handler exceptions without throwing '
        'or crashing dispatcher', () async {
      when(() => mockMessageHandler.handle(any(), any()))
          .thenThrow(Exception('Database disk full'));

      final frame = {
        'event': 'chat:message',
        'payload': {'content': 'fail'},
      };

      expect(dispatcher.dispatch(frame), completes);
    });
  });
}
