import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';

abstract class LiveStreamRemoteDataSource {
  Future<LiveStream> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  });

  Future<LiveStream> getStream(String streamId);

  Future<LiveStream> updateStream(
    String streamId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  });

  Future<LiveStream> startStream(String streamId);

  Future<LiveStream> endStream(String streamId, {String? recordingUrl});

  Future<List<LiveStream>> listStreams({
    String? status,
    String? cursor,
    int? limit,
  });

  Future<List<LiveStream>> listMyStreams({
    String? cursor,
    int? limit,
  });

  Future<void> joinStream(String streamId);

  Future<void> leaveStream(String streamId);

  Future<List<LiveViewer>> listViewers(String streamId, {int? limit});

  Future<List<LiveComment>> listComments(
    String streamId, {
    String? cursor,
    int? limit,
  });

  Future<LiveComment> sendComment(String streamId, String content);

  Future<void> pinComment(String streamId, String commentId);

  Future<void> unpinComment(String streamId, String commentId);

  Future<int> sendReaction(
    String streamId, {
    String reaction = 'heart',
    int count = 1,
  });

  Future<LiveGiftEvent> sendGift(
    String streamId, {
    required String giftType,
    int count = 1,
  });

  Future<List<LiveLeaderboardItem>> getLeaderboard(String streamId);

  Future<LiveCohost> requestCohost(String streamId);

  Future<LiveCohost> respondCohost(
    String streamId, {
    required String userId,
    required String action,
  });

  Future<void> leaveCohost(String streamId);

  Future<List<LiveCohost>> listCohosts(String streamId);
}

class LiveStreamRemoteDataSourceImpl implements LiveStreamRemoteDataSource {
  const LiveStreamRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<LiveStream> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreams,
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (privacy != null) 'privacy': privacy,
        },
      );
      final raw = _extractMap(response.data);
      return LiveStream.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create live stream: $e');
    }
  }

  @override
  Future<LiveStream> getStream(String streamId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamById(streamId),
      );
      final raw = _extractMap(response.data);
      return LiveStream.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to get live stream: $e');
    }
  }

  @override
  Future<LiveStream> updateStream(
    String streamId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    try {
      final response = await _dioClient.patch<dynamic>(
        ApiConstants.livestreamById(streamId),
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (privacy != null) 'privacy': privacy,
        },
      );
      final raw = _extractMap(response.data);
      return LiveStream.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update live stream: $e');
    }
  }

  @override
  Future<LiveStream> startStream(String streamId) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamStart(streamId),
      );
      final raw = _extractMap(response.data);
      return LiveStream.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to start live stream: $e');
    }
  }

  @override
  Future<LiveStream> endStream(String streamId, {String? recordingUrl}) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamEnd(streamId),
        data: {
          if (recordingUrl != null) 'recordingUrl': recordingUrl,
        },
      );
      final raw = _extractMap(response.data);
      return LiveStream.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to end live stream: $e');
    }
  }

  @override
  Future<List<LiveStream>> listStreams({
    String? status,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreams,
        queryParameters: {
          if (status != null) 'status': status,
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return _extractList(response.data).map(LiveStream.fromJson).toList();
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to list live streams: $e');
    }
  }

  @override
  Future<List<LiveStream>> listMyStreams({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamsMe,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return _extractList(response.data).map(LiveStream.fromJson).toList();
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to list my live streams: $e');
    }
  }

  @override
  Future<void> joinStream(String streamId) async {
    try {
      await _dioClient.post<dynamic>(ApiConstants.livestreamJoin(streamId));
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to join live stream: $e');
    }
  }

  @override
  Future<void> leaveStream(String streamId) async {
    try {
      await _dioClient.post<dynamic>(ApiConstants.livestreamLeave(streamId));
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to leave live stream: $e');
    }
  }

  @override
  Future<List<LiveViewer>> listViewers(String streamId, {int? limit}) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamViewers(streamId),
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );
      return _extractList(response.data).map(LiveViewer.fromJson).toList();
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to list live viewers: $e');
    }
  }

  @override
  Future<List<LiveComment>> listComments(
    String streamId, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamComments(streamId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return _extractList(response.data).map(LiveComment.fromJson).toList();
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to list live comments: $e');
    }
  }

  @override
  Future<LiveComment> sendComment(String streamId, String content) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamComments(streamId),
        data: {'content': content},
      );
      final raw = _extractMap(response.data);
      return LiveComment.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to send live comment: $e');
    }
  }

  @override
  Future<void> pinComment(String streamId, String commentId) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.livestreamPinComment(streamId, commentId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to pin live comment: $e');
    }
  }

  @override
  Future<void> unpinComment(String streamId, String commentId) async {
    try {
      await _dioClient.delete<dynamic>(
        ApiConstants.livestreamPinComment(streamId, commentId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to unpin live comment: $e');
    }
  }

  @override
  Future<int> sendReaction(
    String streamId, {
    String reaction = 'heart',
    int count = 1,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamReactions(streamId),
        data: {
          'reaction': reaction,
          'count': count,
        },
      );
      final raw = _extractMap(response.data);
      return (raw['totalLikes'] as num?)?.toInt() ?? 0;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to send live reaction: $e');
    }
  }

  @override
  Future<LiveGiftEvent> sendGift(
    String streamId, {
    required String giftType,
    int count = 1,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamGifts(streamId),
        data: {
          'giftType': giftType,
          'count': count,
        },
      );
      final raw = _extractMap(response.data);
      return LiveGiftEvent.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to send live gift: $e');
    }
  }

  @override
  Future<List<LiveLeaderboardItem>> getLeaderboard(String streamId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamLeaderboard(streamId),
      );
      final raw = _extractMap(response.data);
      final supporters = raw['supporters'];
      if (supporters is List) {
        return supporters
            .whereType<Map<String, dynamic>>()
            .map(LiveLeaderboardItem.fromJson)
            .toList();
      }
      return <LiveLeaderboardItem>[];
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to get live leaderboard: $e');
    }
  }

  @override
  Future<LiveCohost> requestCohost(String streamId) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamCohostRequest(streamId),
      );
      final raw = _extractMap(response.data);
      return LiveCohost.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to request cohost: $e');
    }
  }

  @override
  Future<LiveCohost> respondCohost(
    String streamId, {
    required String userId,
    required String action,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.livestreamCohostRespond(streamId),
        data: {
          'userId': userId,
          'action': action,
        },
      );
      final raw = _extractMap(response.data);
      return LiveCohost.fromJson(raw);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to respond to cohost: $e');
    }
  }

  @override
  Future<void> leaveCohost(String streamId) async {
    try {
      await _dioClient.post<dynamic>(
        ApiConstants.livestreamCohostLeave(streamId),
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to leave cohost: $e');
    }
  }

  @override
  Future<List<LiveCohost>> listCohosts(String streamId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.livestreamCohosts(streamId),
      );
      return _extractList(response.data).map(LiveCohost.fromJson).toList();
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to list cohosts: $e');
    }
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data['items'] ?? data['streams'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return <Map<String, dynamic>>[];
  }
}
