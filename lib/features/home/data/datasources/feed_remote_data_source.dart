import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/home/domain/entities/post_item.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostItem>> getFeed();
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  const FeedRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<List<PostItem>> getFeed() async {
    try {
      final response = await _dioClient.get<dynamic>('/feed');
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PostItem.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic>) {
        final rawItems = data['data'] ?? data['items'] ?? data['feed'];
        if (rawItems is List) {
          return rawItems
              .whereType<Map<String, dynamic>>()
              .map(PostItem.fromJson)
              .toList();
        }
      }

      return <PostItem>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch feed: $e');
    }
  }
}
