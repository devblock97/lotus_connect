import 'package:lotus_connect/features/livestream/domain/entities/live_cohost.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';

abstract class LiveStreamRepository {
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
