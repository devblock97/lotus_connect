import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/presentation/utils/call_peer_display.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';

void main() {
  const friendWithFullName = User(
    id: 'peer-1',
    username: 'alice',
    fullName: 'Alice Wonder',
    email: 'alice@lotus.io',
  );

  const friendWithEmptyFullName = User(
    id: 'peer-2',
    username: 'bob',
    fullName: '',
    email: 'bob@lotus.io',
  );

  group('resolveCallPeerDisplay', () {
    test('returns fullName and uppercase initial when available', () {
      final result = resolveCallPeerDisplay(
        friends: const [friendWithFullName],
        peerId: 'peer-1',
      );

      expect(result.displayName, 'Alice Wonder');
      expect(result.initial, 'A');
    });

    test('falls back to username when fullName is empty', () {
      final result = resolveCallPeerDisplay(
        friends: const [friendWithEmptyFullName],
        peerId: 'peer-2',
      );

      expect(result.displayName, 'bob');
      expect(result.initial, 'B');
    });

    test('handles short peerId without RangeError when friend not found', () {
      final result = resolveCallPeerDisplay(
        friends: const [],
        peerId: 'abc',
      );

      expect(result.displayName, 'abc');
      expect(result.initial, 'A');
    });

    test('truncates long peerId to 8 chars when friend not found', () {
      final result = resolveCallPeerDisplay(
        friends: const [],
        peerId: '1234567890-abcdef',
      );

      expect(result.displayName, '12345678');
      expect(result.initial, '1');
    });

    test('falls back to User when peerId is null or empty', () {
      final result = resolveCallPeerDisplay(
        friends: const [],
        peerId: '',
      );

      expect(result.displayName, 'User');
      expect(result.initial, 'U');
    });
  });

  group('resolveCallLogPeerId', () {
    final createdAt = DateTime(2026, 11, 19, 9);

    test('returns hostId for incoming call logs', () {
      final log = CallLog(
        id: 'log-1',
        hostId: 'peer-1',
        channelId: 'room-1',
        isVideo: false,
        status: 'accepted',
        createdAt: createdAt,
      );

      final peerId = resolveCallLogPeerId(
        log: log,
        currentUserId: 'me-1',
        friends: const [friendWithFullName],
      );

      expect(peerId, 'peer-1');
    });

    test('returns log.peerId for outgoing call logs when populated', () {
      final log = CallLog(
        id: 'log-2',
        hostId: 'me-1',
        peerId: 'peer-2',
        channelId: 'room-2',
        isVideo: true,
        status: 'accepted',
        createdAt: createdAt,
      );

      final peerId = resolveCallLogPeerId(
        log: log,
        currentUserId: 'me-1',
        friends: const [],
      );

      expect(peerId, 'peer-2');
    });

    test('resolves peerId from conversationId when available', () {
      final log = CallLog(
        id: 'log-3',
        hostId: 'me-1',
        conversationId: 'conv-1',
        channelId: 'room-3',
        isVideo: false,
        status: 'accepted',
        createdAt: createdAt,
      );

      final peerId = resolveCallLogPeerId(
        log: log,
        currentUserId: 'me-1',
        friends: const [],
        conversations: [
          Conversation(
            id: 'conv-1',
            title: 'Alice',
            isUserToUser: true,
            peerId: 'peer-1',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        ],
      );

      expect(peerId, 'peer-1');
    });

    test(
      'falls back to matching friend username for outgoing logs without '
      'conversationId',
      () {
        final log = CallLog(
          id: 'log-4',
          hostId: 'me-1',
          username: 'bob',
          channelId: 'room-4',
          isVideo: true,
          status: 'ended',
          createdAt: createdAt,
        );

        final peerId = resolveCallLogPeerId(
          log: log,
          currentUserId: 'me-1',
          friends: const [friendWithFullName, friendWithEmptyFullName],
          currentUsername: 'me_user',
        );

        expect(peerId, 'peer-2');
      },
    );
  });
}
