import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/exception.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/data/datasources/chill_remote_data_source.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_upload_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_view_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/create_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/record_chill_view_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/update_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

/// Concrete implementation of [ChillRepository] backed by [ChillRemoteDataSource].
class ChillRepositoryImpl implements ChillRepository {
  const ChillRepositoryImpl({
    required ChillRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ChillRemoteDataSource _remoteDataSource;

  Failure _handleException(Object error, String operation) {
    AppLogger.error('ChillRepositoryImpl.$operation error: $error');
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    return ServerFailure('Unexpected error during $operation: $error');
  }

  @override
  FutureResult<List<ChillItem>> getChillFeed({
    String? cursor,
    int? limit,
    String? tag,
  }) async {
    try {
      final items = await _remoteDataSource.getChillFeed(
        cursor: cursor,
        limit: limit,
        tag: tag,
      );
      return Right(items);
    } on Object catch (e) {
      return Left(_handleException(e, 'getChillFeed'));
    }
  }

  @override
  FutureResult<List<ChillItem>> getExploreChills({
    String? cursor,
    int? limit,
    String? tag,
  }) async {
    try {
      final items = await _remoteDataSource.getExploreChills(
        cursor: cursor,
        limit: limit,
        tag: tag,
      );
      return Right(items);
    } on Object catch (e) {
      return Left(_handleException(e, 'getExploreChills'));
    }
  }

  @override
  FutureResult<ChillItem> getChillById(String chillId) async {
    try {
      final item = await _remoteDataSource.getChillById(chillId);
      return Right(item);
    } on Object catch (e) {
      return Left(_handleException(e, 'getChillById'));
    }
  }

  @override
  FutureResult<List<ChillItem>> getUserChills(
    String userId, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final items = await _remoteDataSource.getUserChills(
        userId,
        cursor: cursor,
        limit: limit,
      );
      return Right(items);
    } on Object catch (e) {
      return Left(_handleException(e, 'getUserChills'));
    }
  }

  @override
  FutureResult<List<ChillItem>> getMyChills({
    String? cursor,
    int? limit,
  }) async {
    try {
      final items = await _remoteDataSource.getMyChills(
        cursor: cursor,
        limit: limit,
      );
      return Right(items);
    } on Object catch (e) {
      return Left(_handleException(e, 'getMyChills'));
    }
  }

  @override
  FutureResult<ChillItem> createChill(CreateChillParams params) async {
    try {
      final item = await _remoteDataSource.createChill(params);
      return Right(item);
    } on Object catch (e) {
      return Left(_handleException(e, 'createChill'));
    }
  }

  @override
  FutureResult<ChillItem> updateChill(UpdateChillParams params) async {
    try {
      final item = await _remoteDataSource.updateChill(params);
      return Right(item);
    } on Object catch (e) {
      return Left(_handleException(e, 'updateChill'));
    }
  }

  @override
  FutureResult<bool> deleteChill(String chillId) async {
    try {
      final success = await _remoteDataSource.deleteChill(chillId);
      return Right(success);
    } on Object catch (e) {
      return Left(_handleException(e, 'deleteChill'));
    }
  }

  @override
  FutureResult<bool> toggleLikeChill(
    String chillId, {
    required bool isLiked,
    String? reaction,
  }) async {
    try {
      final success = await _remoteDataSource.toggleLikeChill(
        chillId,
        isLiked: isLiked,
        reaction: reaction,
      );
      return Right(success);
    } on Object catch (e) {
      return Left(_handleException(e, 'toggleLikeChill'));
    }
  }

  @override
  FutureResult<bool> toggleSaveChill(
    String chillId, {
    required bool isSaved,
  }) async {
    try {
      final success = await _remoteDataSource.toggleSaveChill(
        chillId,
        isSaved: isSaved,
      );
      return Right(success);
    } on Object catch (e) {
      return Left(_handleException(e, 'toggleSaveChill'));
    }
  }

  @override
  FutureResult<ChillViewResult> recordChillView(
    RecordChillViewParams params,
  ) async {
    try {
      final result = await _remoteDataSource.recordChillView(params);
      return Right(result);
    } on Object catch (e) {
      return Left(_handleException(e, 'recordChillView'));
    }
  }

  @override
  FutureResult<ChillItem> shareChill(String chillId) async {
    try {
      final item = await _remoteDataSource.shareChill(chillId);
      return Right(item);
    } on Object catch (e) {
      return Left(_handleException(e, 'shareChill'));
    }
  }

  @override
  FutureResult<ChillUploadResult> uploadChillVideo(String filePath) async {
    try {
      final result = await _remoteDataSource.uploadChillVideo(filePath);
      return Right(result);
    } on Object catch (e) {
      return Left(_handleException(e, 'uploadChillVideo'));
    }
  }
}
