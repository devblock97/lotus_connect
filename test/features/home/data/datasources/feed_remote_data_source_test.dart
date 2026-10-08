import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/data/datasources/feed_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;
  late FeedRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = FeedRemoteDataSourceImpl(dioClient: mockDioClient);
  });

  group('FeedRemoteDataSource', () {
    const rawFeedJson = [
      {
        'id': 'post_1',
        'author': {
          'id': 'author_1',
          'username': 'nnthong',
          'fullName': 'Nguyen Nhu Thong',
        },
        'content': 'Hello from Dong Thap',
        'mediaItems': <Map<String, dynamic>>[],
        'likeCount': 5,
        'commentCount': 2,
      },
    ];

    test('successfully fetches and parses feed list from /api/v1/feed',
        () async {
      when(
        () => mockDioClient.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/v1/feed'),
          data: rawFeedJson,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getFeed();

      expect(result.length, 1);
      expect(result.first.id, 'post_1');
      expect(result.first.author.username, 'nnthong');
      expect(result.first.content, 'Hello from Dong Thap');
      expect(result.first.likeCount, 5);
    });

    test('throws ServerException when dioClient fails', () async {
      when(
        () => mockDioClient.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/feed'),
          error: 'Connection error',
        ),
      );

      expect(dataSource.getFeed, throwsA(isA<ServerException>()));
    });

    test('successfully creates a post via POST /posts', () async {
      const createdPostJson = {
        'id': 'post_created_123',
        'author': {
          'id': 'author_1',
          'username': 'nnthong',
          'fullName': 'Nguyen Nhu Thong',
        },
        'content': 'Exploring the serene beauty of the countryside! 🌿✨',
        'mediaItems': <Map<String, dynamic>>[],
        'visibility': 'public',
        'likeCount': 0,
        'commentCount': 0,
        'userHasLiked': false,
        'createdAt': '2026-09-18T14:30:00Z',
      };

      when(
        () => mockDioClient.post<dynamic>(
          any(),
          data: any<dynamic>(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/posts'),
          data: createdPostJson,
          statusCode: 200,
        ),
      );

      final result = await dataSource.createPost(
        content: 'Exploring the serene beauty of the countryside! 🌿✨',
      );

      expect(result.id, 'post_created_123');
      expect(result.author.username, 'nnthong');
      expect(
        result.content,
        'Exploring the serene beauty of the countryside! 🌿✨',
      );
      expect(result.visibility, 'public');
    });

    test('successfully deletes a post via DELETE /posts/:id', () async {
      when(
        () => mockDioClient.delete<dynamic>(
          any(),
          data: any<dynamic>(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/posts/post_123'),
          data: {'success': true},
          statusCode: 200,
        ),
      );

      final result = await dataSource.deletePost('post_123');
      expect(result, isTrue);
    });
  });
}
