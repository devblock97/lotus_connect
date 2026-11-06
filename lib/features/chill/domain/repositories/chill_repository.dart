import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_item.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_upload_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/chill_view_result.dart';
import 'package:lotus_connect/features/chill/domain/entities/create_chill_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/record_chill_view_params.dart';
import 'package:lotus_connect/features/chill/domain/entities/update_chill_params.dart';

/// Contract defining all Chill (Reels) feature operations matching `lotus_connect_system`.
abstract class ChillRepository {
  /// Fetches the continuous vertical feed of Chill reels with pagination and tag filter support.
  FutureResult<List<ChillItem>> getChillFeed({
    String? cursor,
    int? limit,
    String? tag,
  });

  /// Fetches trending/explore Chill reels.
  FutureResult<List<ChillItem>> getExploreChills({
    String? cursor,
    int? limit,
    String? tag,
  });

  /// Fetches a specific Chill by its identifier.
  FutureResult<ChillItem> getChillById(String chillId);

  /// Fetches Chill reels published by a specific user.
  FutureResult<List<ChillItem>> getUserChills(
    String userId, {
    String? cursor,
    int? limit,
  });

  /// Fetches Chill reels published by the authenticated user.
  FutureResult<List<ChillItem>> getMyChills({String? cursor, int? limit});

  /// Creates and publishes a new Chill reel.
  FutureResult<ChillItem> createChill(CreateChillParams params);

  /// Updates an existing Chill reel (caption, audio, tags, visibility, etc.).
  FutureResult<ChillItem> updateChill(UpdateChillParams params);

  /// Deletes a Chill reel by id.
  FutureResult<bool> deleteChill(String chillId);

  /// Toggles like/reaction state on a Chill.
  FutureResult<bool> toggleLikeChill(
    String chillId, {
    required bool isLiked,
    String? reaction,
  });

  /// Toggles bookmark/saved state on a Chill.
  FutureResult<bool> toggleSaveChill(String chillId, {required bool isSaved});

  /// Records a view event, watch time duration, and completion analytics.
  FutureResult<ChillViewResult> recordChillView(RecordChillViewParams params);

  /// Records a share event on a Chill and returns updated Chill with incremented shareCount.
  FutureResult<ChillItem> shareChill(String chillId);

  /// Uploads a raw video file from local filesystem to storage.
  FutureResult<ChillUploadResult> uploadChillVideo(String filePath);
}
