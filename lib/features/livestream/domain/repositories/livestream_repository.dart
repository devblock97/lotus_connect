import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';

abstract class LiveStreamRepository {
  FutureResult<LiveStream> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  });

  FutureResult<LiveStream> getStream(String streamId);

  FutureResult<LiveStream> updateStream(
    String streamId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  });

  FutureResult<LiveStream> startStream(String streamId);

  FutureResult<LiveStream> endStream(String streamId, {String? recordingUrl});

  FutureResult<List<LiveStream>> listStreams({
    String? status,
    String? cursor,
    int? limit,
  });

  FutureResult<List<LiveStream>> listMyStreams({
    String? cursor,
    int? limit,
  });

  FutureResult<void> joinStream(String streamId);

  FutureResult<void> leaveStream(String streamId);

  FutureResult<List<LiveViewer>> listViewers(String streamId, {int? limit});

  FutureResult<List<LiveComment>> listComments(
    String streamId, {
    String? cursor,
    int? limit,
  });

  FutureResult<LiveComment> sendComment(String streamId, String content);

  FutureResult<void> pinComment(String streamId, String commentId);

  FutureResult<void> unpinComment(String streamId, String commentId);

  FutureResult<int> sendReaction(
    String streamId, {
    String reaction = 'heart',
    int count = 1,
  });

  FutureResult<LiveGiftEvent> sendGift(
    String streamId, {
    required String giftType,
    int count = 1,
  });

  FutureResult<List<LiveLeaderboardItem>> getLeaderboard(String streamId);

  FutureResult<LiveCohost> requestCohost(String streamId);

  FutureResult<LiveCohost> respondCohost(
    String streamId, {
    required String userId,
    required String action,
  });

  FutureResult<void> leaveCohost(String streamId);

  FutureResult<List<LiveCohost>> listCohosts(String streamId);
}
