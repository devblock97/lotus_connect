import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';

void main() {
  group('LiveStream Entity & DTO Tests', () {
    test('parses LiveStream from JSON correctly matching lotus_connect_system',
        () {
      final json = {
        'id': '019fd810-74a0-7112-9840-001122334455',
        'host': {
          'id': '019fa983-9f8c-7fc0-a285-fef0a8b88064',
          'username': 'janedoe',
          'fullName': 'Jane Doe',
          'avatarUrl': 'http://localhost:8080/uploads/jane.jpg',
        },
        'title': 'Acoustic Night & Q&A 🎸✨',
        'description': 'Playing songs and chatting with viewers!',
        'thumbnailUrl': 'http://localhost:8080/uploads/live-thumb.jpg',
        'status': 'live',
        'privacy': 'public',
        'playbackUrl':
            'http://localhost:8080/api/v1/livestreams/019fd810/play.m3u8',
        'channelId': 'live-room-019fd810',
        'viewerCount': 42,
        'peakViewers': 128,
        'totalViews': 540,
        'likeCount': 3420,
        'pinnedCommentId': '019fd830-5555-7666-8777-888899990000',
        'startedAt': '2026-10-10T10:00:00Z',
        'endedAt': null,
        'durationSeconds': 3600,
        'recordingUrl': null,
        'isHost': true,
        'streamKey': 'live_sk_a8f9c1b2d3e4f50123456789',
        'ingestUrl':
            'rtmp://localhost:8080/live/live_sk_a8f9c1b2d3e4f50123456789',
        'createdAt': '2026-10-10T10:00:00Z',
        'updatedAt': '2026-10-10T10:00:00Z',
      };

      final stream = LiveStream.fromJson(json);

      expect(stream.id, '019fd810-74a0-7112-9840-001122334455');
      expect(stream.host.username, 'janedoe');
      expect(stream.title, 'Acoustic Night & Q&A 🎸✨');
      expect(stream.isLive, isTrue);
      expect(stream.isEnded, isFalse);
      expect(stream.isHost, isTrue);
      expect(stream.viewerCount, 42);
      expect(stream.likeCount, 3420);
      expect(stream.streamKey, 'live_sk_a8f9c1b2d3e4f50123456789');
    });

    test('parses LiveComment and LiveGiftEvent correctly', () {
      final commentJson = {
        'id': 'comment-123',
        'streamId': 'stream-456',
        'user': {
          'id': 'user-789',
          'username': 'alex',
        },
        'content': 'Great live stream! 🔥',
        'isPinned': true,
        'createdAt': '2026-10-10T10:05:00Z',
      };

      final comment = LiveComment.fromJson(commentJson);
      expect(comment.id, 'comment-123');
      expect(comment.content, 'Great live stream! 🔥');
      expect(comment.isPinned, isTrue);

      final giftJson = {
        'id': 'gift-999',
        'streamId': 'stream-456',
        'sender': {
          'id': 'user-789',
          'username': 'alex',
        },
        'giftType': 'rocket',
        'giftCount': 1,
        'coinAmount': 500,
        'comboCount': 2,
        'createdAt': '2026-10-10T10:06:00Z',
      };

      final gift = LiveGiftEvent.fromJson(giftJson);
      expect(gift.giftType, 'rocket');
      expect(gift.coinAmount, 500);
      expect(gift.giftDefinition.name, 'Rocket');
      expect(gift.giftDefinition.icon, '🚀');
    });

    test('LiveGiftType catalog contains supported TikTok gifts', () {
      expect(LiveGiftType.all.length, 7);
      expect(LiveGiftType.fromId('rose').coins, 1);
      expect(LiveGiftType.fromId('rocket').coins, 500);
      expect(LiveGiftType.fromId('crown').coins, 1000);
    });

    test('LiveStream default isHost is false for viewers', () {
      final json = {
        'id': 'stream-123',
        'host': {
          'id': 'host-user-id',
          'username': 'streamer',
        },
        'title': 'TikTok style Live Stream',
        'status': 'live',
      };

      final stream = LiveStream.fromJson(json);
      expect(stream.isHost, isFalse);
    });
  });
}
