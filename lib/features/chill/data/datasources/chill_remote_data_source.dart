import 'package:dio/dio.dart';
import 'package:lotus_connect/core/constants/api_constants.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chill/data/models/chill_model.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_upload_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_view_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/create_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/record_chill_view_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/update_chill_params.dart';

abstract class ChillRemoteDataSource {
  Future<List<ChillItem>> getChillFeed({
    String? cursor,
    int? limit,
    String? tag,
  });

  Future<List<ChillItem>> getExploreChills({
    String? cursor,
    int? limit,
    String? tag,
  });

  Future<ChillItem> getChillById(String chillId);

  Future<List<ChillItem>> getUserChills(
    String userId, {
    String? cursor,
    int? limit,
  });

  Future<List<ChillItem>> getMyChills({String? cursor, int? limit});

  Future<ChillItem> createChill(CreateChillParams params);

  Future<ChillItem> updateChill(UpdateChillParams params);

  Future<bool> deleteChill(String chillId);

  Future<bool> toggleLikeChill(
    String chillId, {
    required bool isLiked,
    String? reaction,
  });

  Future<bool> toggleSaveChill(String chillId, {required bool isSaved});

  Future<ChillViewResult> recordChillView(RecordChillViewParams params);

  Future<ChillItem> shareChill(String chillId);

  Future<ChillUploadResult> uploadChillVideo(String filePath);
}

class ChillRemoteDataSourceImpl implements ChillRemoteDataSource {
  const ChillRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  List<ChillItem> _parseChillList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => ChillModel.fromJson(json).toEntity())
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final rawItems = data['data'] ??
          data['items'] ??
          data['chills'] ??
          data['reels'] ??
          data['results'];
      if (rawItems is List) {
        return rawItems
            .whereType<Map<String, dynamic>>()
            .map((json) => ChillModel.fromJson(json).toEntity())
            .toList();
      }
    }

    return <ChillItem>[];
  }

  @override
  Future<List<ChillItem>> getChillFeed({
    String? cursor,
    int? limit,
    String? tag,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.chillFeed,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
          if (tag != null) 'tag': tag,
        },
      );
      return _parseChillList(response.data);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch chill feed: $e');
    }
  }

  @override
  Future<List<ChillItem>> getExploreChills({
    String? cursor,
    int? limit,
    String? tag,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.chillExplore,
        queryParameters: {
          'filter': 'chill',
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
          if (tag != null) 'tag': tag,
        },
      );
      return _parseChillList(response.data);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch explore chills: $e');
    }
  }

  @override
  Future<ChillItem> getChillById(String chillId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.chillById(chillId),
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final chillData = data['data'] ?? data['chill'] ?? data;
        if (chillData is Map<String, dynamic>) {
          return ChillModel.fromJson(chillData).toEntity();
        }
      }

      throw ServerException('Invalid response structure for chill $chillId');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch chill details: $e');
    }
  }

  @override
  Future<List<ChillItem>> getUserChills(
    String userId, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.userChills(userId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return _parseChillList(response.data);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch user chills: $e');
    }
  }

  @override
  Future<List<ChillItem>> getMyChills({String? cursor, int? limit}) async {
    try {
      final response = await _dioClient.get<dynamic>(
        ApiConstants.myChills,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return _parseChillList(response.data);
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch my chills: $e');
    }
  }

  @override
  Future<ChillItem> createChill(CreateChillParams params) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.chills,
        data: params.toJson(),
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final chillData = data['data'] ?? data['chill'] ?? data;
        if (chillData is Map<String, dynamic>) {
          return ChillModel.fromJson(chillData).toEntity();
        }
      }

      throw const ServerException('Invalid response when creating chill');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create chill: $e');
    }
  }

  @override
  Future<ChillItem> updateChill(UpdateChillParams params) async {
    try {
      final response = await _dioClient.patch<dynamic>(
        ApiConstants.chillById(params.chillId),
        data: params.toJson(),
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final chillData = data['data'] ?? data['chill'] ?? data;
        if (chillData is Map<String, dynamic>) {
          return ChillModel.fromJson(chillData).toEntity();
        }
      }

      throw const ServerException('Invalid response when updating chill');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update chill: $e');
    }
  }

  @override
  Future<bool> deleteChill(String chillId) async {
    try {
      final response = await _dioClient.delete<dynamic>(
        ApiConstants.chillById(chillId),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['success'] as bool? ?? true;
      }
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete chill: $e');
    }
  }

  @override
  Future<bool> toggleLikeChill(
    String chillId, {
    required bool isLiked,
    String? reaction,
  }) async {
    try {
      final response = isLiked
          ? await _dioClient.post<dynamic>(
              ApiConstants.chillReactions(chillId),
              data: {
                'reaction': reaction ?? 'like',
              },
            )
          : await _dioClient.delete<dynamic>(
              ApiConstants.chillReactions(chillId),
            );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['success'] as bool? ?? true;
      }
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to toggle like on chill: $e');
    }
  }

  @override
  Future<bool> toggleSaveChill(String chillId, {required bool isSaved}) async {
    try {
      final response = isSaved
          ? await _dioClient.post<dynamic>(ApiConstants.chillSave(chillId))
          : await _dioClient.delete<dynamic>(ApiConstants.chillSave(chillId));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['success'] as bool? ?? true;
      }
      return true;
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to toggle save chill: $e');
    }
  }

  @override
  Future<ChillViewResult> recordChillView(RecordChillViewParams params) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.chillView(params.chillId),
        data: params.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChillViewResult.fromJson(data);
      }
      return ChillViewResult(
        postId: params.chillId,
        viewCount: 1,
        watchTimeSeconds: params.watchTimeSeconds ?? 0.0,
        isCompleted: params.isCompleted ?? false,
      );
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to record chill view: $e');
    }
  }

  @override
  Future<ChillItem> shareChill(String chillId) async {
    try {
      final response = await _dioClient.post<dynamic>(
        ApiConstants.chillShare(chillId),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final chillData = data['data'] ?? data['chill'] ?? data;
        if (chillData is Map<String, dynamic>) {
          return ChillModel.fromJson(chillData).toEntity();
        }
      }
      throw const ServerException('Invalid response structure on share chill');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to record chill share: $e');
    }
  }

  @override
  Future<ChillUploadResult> uploadChillVideo(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dioClient.post<dynamic>(
        ApiConstants.upload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final fileData = data['file'] ?? data['data'] ?? data;
        if (fileData is Map<String, dynamic>) {
          return ChillUploadResult.fromJson(fileData);
        }
        if (data.containsKey('url') || data.containsKey('videoUrl')) {
          return ChillUploadResult.fromJson(data);
        }
      }

      throw const ServerException('Failed to parse uploaded chill video');
    } on Object catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to upload chill video: $e');
    }
  }
}
