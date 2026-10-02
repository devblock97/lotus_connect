import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/data/datasources/story_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;
  late StoryRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = StoryRemoteDataSourceImpl(dioClient: mockDioClient);
  });

  group('StoryRemoteDataSource', () {
    const rawStoriesTrayJson = [
      {
        'user': {
          'id': '01a0e08b-446f-72e0-8ec2-c827c68c0ad1',
          'username': 'johnnguyen',
          'fullName': 'John Nguyen',
          'avatarUrl': null,
        },
        'stories': [
          {
            'id': '01a0f650-c2da-7b52-81d8-a56223fc7d38',
            'author': {
              'id': '01a0e08b-446f-72e0-8ec2-c827c68c0ad1',
              'username': 'johnnguyen',
              'fullName': 'John Nguyen',
              'avatarUrl': null,
            },
            'mediaType': 'image',
            'mediaUrl':
                'https://mia.vn/media/uploads/blog-du-lich/kham-pha-thanh-duong-cu-lao-gieng-thanh-duong-ho-dau-nuoc-o-an-giang-6-1660649579.jpg',
            'thumbnailUrl':
                'https://mia.vn/media/uploads/blog-du-lich/kham-pha-thanh-duong-cu-lao-gieng-thanh-duong-ho-dau-nuoc-o-an-giang-6-1660649579.jpg',
            'caption': 'Sunset golden hour at the beach! 🌅✨',
            'duration': 12.0,
            'visibility': 'close_friends',
            'backgroundColor': '#1A1A24',
            'metadata': null,
            'createdAt': '2026-10-01T07:14:43.137121Z',
            'expiresAt': '2026-10-02T07:14:43.034977Z',
            'viewCount': 0,
            'hasViewed': false,
            'viewerReaction': null,
            'isCloseFriend': false,
          },
          {
            'id': '01a0f654-a0cf-71c3-a80d-37496bce6190',
            'author': {
              'id': '01a0e08b-446f-72e0-8ec2-c827c68c0ad1',
              'username': 'johnnguyen',
              'fullName': 'John Nguyen',
              'avatarUrl': null,
            },
            'mediaType': 'image',
            'mediaUrl':
                'https://media.vietravel.com/images/Content/du-lich-khu-bao-ron-sinh-thai-dong-thap-muoi-mien-tay-4.png',
            'thumbnailUrl':
                'https://media.vietravel.com/images/Content/du-lich-khu-bao-ron-sinh-thai-dong-thap-muoi-mien-tay-4.png',
            'caption': 'Sunset golden hour at village!',
            'duration': 12.0,
            'visibility': 'close_friends',
            'backgroundColor': '#666699',
            'metadata': null,
            'createdAt': '2026-10-01T07:18:56.562813Z',
            'expiresAt': '2026-10-02T07:18:56.463144Z',
            'viewCount': 0,
            'hasViewed': false,
            'viewerReaction': null,
            'isCloseFriend': false,
          }
        ],
        'hasUnseen': true,
        'totalStories': 2,
        'latestStoryCreatedAt': '2026-10-01T07:18:56.562813Z',
        'hasCloseFriendsStory': true,
        'isSelf': true,
      }
    ];

    test(
        'successfully fetches and parses stories tray from '
        'ApiConstants.storiesTray', () async {
      when(
        () => mockDioClient.get<dynamic>(
          ApiConstants.storiesTray,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: ApiConstants.storiesTray),
          data: rawStoriesTrayJson,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getStoriesTray();

      expect(result.length, 1);
      final userStory = result.first;
      expect(userStory.user.username, 'johnnguyen');
      expect(userStory.user.fullName, 'John Nguyen');
      expect(userStory.hasUnseen, true);
      expect(userStory.hasCloseFriendsStory, true);
      expect(userStory.isSelf, true);
      expect(userStory.stories.length, 2);

      final firstStory = userStory.stories.first;
      expect(firstStory.id, '01a0f650-c2da-7b52-81d8-a56223fc7d38');
      expect(firstStory.caption, 'Sunset golden hour at the beach! 🌅✨');
      expect(firstStory.duration, 12.0);
      expect(firstStory.visibility, 'close_friends');
      expect(firstStory.isCloseFriendsStory, true);
      expect(firstStory.backgroundColor, '#1A1A24');
    });

    test('markStoryViewed posts to markStoryViewed endpoint', () async {
      when(
        () => mockDioClient.post<dynamic>(
          ApiConstants.markStoryViewed('story_123'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/stories/story_123/view'),
          statusCode: 200,
        ),
      );

      await dataSource.markStoryViewed('story_123');

      verify(
        () => mockDioClient.post<dynamic>(
          ApiConstants.markStoryViewed('story_123'),
        ),
      ).called(1);
    });

    test('reactToStory posts reaction to storyReactions endpoint', () async {
      when(
        () => mockDioClient.post<dynamic>(
          ApiConstants.storyReactions('story_123'),
          data: {'reaction': '❤️'},
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/stories/story_123/reactions'),
          statusCode: 200,
        ),
      );

      await dataSource.reactToStory('story_123', '❤️');

      verify(
        () => mockDioClient.post<dynamic>(
          ApiConstants.storyReactions('story_123'),
          data: {'reaction': '❤️'},
        ),
      ).called(1);
    });

    test('throws ServerException on network error', () async {
      when(
        () => mockDioClient.get<dynamic>(
          any<String>(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(Exception('Server error'));

      expect(
        () => dataSource.getStoriesTray(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
