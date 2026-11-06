import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/features/chill/chill_domain.dart';
import 'package:lotus_connect/features/chill/data/models/chill_model.dart';

void main() {
  group('ChillItem & ChillModel Tests (lotus_connect_system matching)', () {
    test('parses ChillItem from unified PostResponse JSON correctly', () {
      final json = {
        'id': '019fd850-8a12-70b1-8b01-f2d47e8e29ba',
        'author': {
          'id': '019fb231-20c0-7cf1-84d5-dd053a261255',
          'username': 'johndoe',
          'fullName': 'John Doe',
          'avatarUrl': 'http://localhost:8080/uploads/avatar.jpg',
        },
        'postType': 'chill',
        'content': 'Sunset golden hour in Da Nang 🌅✨ #travel #vietnam #chills',
        'mediaItems': [
          {
            'url':
                'http://localhost:8080/uploads/transcoded/019fd530-8a12/master.m3u8',
            'thumbnailUrl':
                'http://localhost:8080/uploads/transcoded/019fd530-8a12/thumbnail.jpg',
            'fileName': 'master.m3u8',
            'fileSize': null,
            'mimeType': 'application/x-mpegURL',
            'duration': 15,
            'width': 1080,
            'height': 1920,
          }
        ],
        'visibility': 'public',
        'likeCount': 128,
        'commentCount': 16,
        'shareCount': 42,
        'viewCount': 2450,
        'userHasLiked': true,
        'userReaction': 'love',
        'videoUrl':
            'http://localhost:8080/uploads/transcoded/019fd530-8a12/master.m3u8',
        'thumbnailUrl':
            'http://localhost:8080/uploads/transcoded/019fd530-8a12/thumbnail.jpg',
        'duration': 15.0,
        'width': 1080,
        'height': 1920,
        'audioTitle': 'Original Audio - johndoe',
        'audioArtist': 'John Doe',
        'audioUrl': null,
        'remixParentId': null,
        'isRemix': false,
        'tags': ['travel', 'vietnam', 'chills'],
        'metadata': {
          'aspectRatio': '9:16',
        },
        'createdAt': '2026-11-04T10:00:00Z',
        'updatedAt': '2026-11-04T10:00:00Z',
      };

      final item = ChillItem.fromJson(json);

      expect(item.id, '019fd850-8a12-70b1-8b01-f2d47e8e29ba');
      expect(item.author.username, 'johndoe');
      expect(item.author.fullName, 'John Doe');
      expect(item.postType, 'chill');
      expect(item.caption, contains('#travel'));
      expect(
        item.videoUrl,
        'http://localhost:8080/uploads/transcoded/019fd530-8a12/master.m3u8',
      );
      expect(item.duration, 15.0);
      expect(item.width, 1080);
      expect(item.height, 1920);
      expect(item.aspectRatio, closeTo(1080 / 1920, 0.001));
      expect(item.audioTitle, 'Original Audio - johndoe');
      expect(item.audio?.artist, 'John Doe');
      expect(item.likeCount, 128);
      expect(item.commentCount, 16);
      expect(item.shareCount, 42);
      expect(item.viewCount, 2450);
      expect(item.userHasLiked, isTrue);
      expect(item.userReaction, 'love');
      expect(item.tags, contains('vietnam'));
      expect(item.mediaItems.length, 1);
    });

    test('ChillViewResult parses correctly from PostViewResponse', () {
      final json = {
        'postId': '019fd850-8a12-70b1-8b01-f2d47e8e29ba',
        'viewCount': 2451,
        'watchTimeSeconds': 14.8,
        'isCompleted': true,
      };

      final viewResult = ChillViewResult.fromJson(json);

      expect(viewResult.postId, '019fd850-8a12-70b1-8b01-f2d47e8e29ba');
      expect(viewResult.viewCount, 2451);
      expect(viewResult.watchTimeSeconds, 14.8);
      expect(viewResult.isCompleted, isTrue);
    });

    test('ChillModel maps toEntity correctly', () {
      final json = {
        'id': 'chill_123',
        'authorId': 'author_456',
        'username': 'chill_master',
        'video_url': 'http://localhost:8080/video.mp4',
        'like_count': 50,
        'is_liked': true,
        'created_at': '2026-11-04T10:00:00Z',
      };

      final model = ChillModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 'chill_123');
      expect(entity.author.username, 'chill_master');
      expect(entity.videoUrl, 'http://localhost:8080/video.mp4');
      expect(entity.likeCount, 50);
      expect(entity.userHasLiked, isTrue);
    });

    test('CreateChillParams serializes with postType: chill', () {
      const params = CreateChillParams(
        videoUrl: 'http://localhost:8080/my_reel.mp4',
        caption: 'My first chill video',
        audioTitle: 'Original Audio',
        tags: ['chill', 'reels'],
      );

      final json = params.toJson();
      expect(json['postType'], 'chill');
      expect(json['videoUrl'], 'http://localhost:8080/my_reel.mp4');
      expect(json['caption'], 'My first chill video');
      expect(json['audioTitle'], 'Original Audio');
      expect(json['tags'], ['chill', 'reels']);
      expect(json['visibility'], 'public');
    });

    test('UpdateChillParams serializes properly', () {
      const params = UpdateChillParams(
        chillId: 'chill_123',
        caption: 'Updated caption',
        audioTitle: 'New Audio',
        visibility: 'friends',
      );

      final json = params.toJson();
      expect(json['caption'], 'Updated caption');
      expect(json['audioTitle'], 'New Audio');
      expect(json['visibility'], 'friends');
    });
  });
}
