import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/services/websocket/websocket_service.dart';
import 'package:lotus_connect/features/home/domain/entities/post_author.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';

class LiveReactionEvent {
  const LiveReactionEvent({
    required this.streamId,
    required this.reaction,
    required this.count,
    required this.totalLikes,
    this.user,
  });

  final String streamId;
  final String reaction;
  final int count;
  final int totalLikes;
  final PostAuthor? user;
}

class LiveViewerChangeEvent {
  const LiveViewerChangeEvent({
    required this.streamId,
    required this.viewerCount,
    required this.isJoin,
    this.user,
    this.userId,
  });

  final String streamId;
  final int viewerCount;
  final PostAuthor? user;
  final String? userId;
  final bool isJoin;
}

class LiveEndedEvent {
  const LiveEndedEvent({
    required this.streamId,
    required this.duration,
    required this.peakViewers,
    required this.totalViews,
    required this.totalLikes,
    this.recordingUrl,
  });

  final String streamId;
  final int duration;
  final int peakViewers;
  final int totalViews;
  final int totalLikes;
  final String? recordingUrl;
}

class LiveStreamWsService {
  LiveStreamWsService({required WebSocketService webSocketService})
      : _webSocketService = webSocketService {
    _subscribe();
  }

  final WebSocketService _webSocketService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  String? _activeStreamId;

  final _commentController = StreamController<LiveComment>.broadcast();
  final _reactionController = StreamController<LiveReactionEvent>.broadcast();
  final _giftController = StreamController<LiveGiftEvent>.broadcast();
  final _viewerChangeController =
      StreamController<LiveViewerChangeEvent>.broadcast();
  final _pinnedCommentController = StreamController<String?>.broadcast();
  final _endedController = StreamController<LiveEndedEvent>.broadcast();
  final _startedController = StreamController<LiveStream>.broadcast();

  Stream<LiveComment> get commentStream => _commentController.stream;
  Stream<LiveReactionEvent> get reactionStream => _reactionController.stream;
  Stream<LiveGiftEvent> get giftStream => _giftController.stream;
  Stream<LiveViewerChangeEvent> get viewerChangeStream =>
      _viewerChangeController.stream;
  Stream<String?> get pinnedCommentStream => _pinnedCommentController.stream;
  Stream<LiveEndedEvent> get endedStream => _endedController.stream;
  Stream<LiveStream> get startedStream => _startedController.stream;

  void joinRoom(String streamId) {
    _activeStreamId = streamId;
    _webSocketService.send('livestream:join', {'streamId': streamId});
    AppLogger.info('LiveStream WS: joined room $streamId');
  }

  void leaveRoom(String streamId) {
    if (_activeStreamId == streamId) {
      _activeStreamId = null;
    }
    _webSocketService.send('livestream:leave', {'streamId': streamId});
    AppLogger.info('LiveStream WS: left room $streamId');
  }

  void _subscribe() {
    _subscription = _webSocketService.eventStream.listen((eventFrame) {
      final event = eventFrame['event'] as String?;
      final payload = eventFrame['payload'] as Map<String, dynamic>? ?? {};

      if (event == null) return;

      final streamId =
          payload['streamId'] as String? ?? payload['id'] as String?;
      if (_activeStreamId != null &&
          streamId != null &&
          streamId != _activeStreamId) {
        // Stream lifecycle events should be processed globally
        // even if user is in another stream
        if (event != 'livestream:ended' && event != 'livestream:started') {
          return;
        }
      }

      switch (event) {
        case 'livestream:comment':
          try {
            final comment = LiveComment.fromJson(payload);
            _commentController.add(comment);
          } on Object catch (e) {
            AppLogger.error('Failed to parse live comment frame: $e');
          }

        case 'livestream:reaction':
          try {
            final userJson = payload['user'];
            final user = userJson is Map<String, dynamic>
                ? PostAuthor.fromJson(userJson)
                : null;
            final reaction = payload['reaction'] as String? ?? 'heart';
            final count = (payload['count'] as num?)?.toInt() ?? 1;
            final totalLikes = (payload['totalLikes'] as num?)?.toInt() ?? 0;

            _reactionController.add(
              LiveReactionEvent(
                streamId: streamId ?? '',
                reaction: reaction,
                count: count,
                totalLikes: totalLikes,
                user: user,
              ),
            );
          } on Object catch (e) {
            AppLogger.error('Failed to parse live reaction frame: $e');
          }

        case 'livestream:gift':
          try {
            final gift = LiveGiftEvent.fromJson(payload);
            _giftController.add(gift);
          } on Object catch (e) {
            AppLogger.error('Failed to parse live gift frame: $e');
          }

        case 'livestream:viewer_joined':
          try {
            final userJson = payload['user'];
            final user = userJson is Map<String, dynamic>
                ? PostAuthor.fromJson(userJson)
                : null;
            final viewerCount = (payload['viewerCount'] as num?)?.toInt() ?? 0;

            _viewerChangeController.add(
              LiveViewerChangeEvent(
                streamId: streamId ?? '',
                viewerCount: viewerCount,
                user: user,
                isJoin: true,
              ),
            );
          } on Object catch (e) {
            AppLogger.error('Failed to parse viewer_joined frame: $e');
          }

        case 'livestream:viewer_left':
          try {
            final viewerCount = (payload['viewerCount'] as num?)?.toInt() ?? 0;
            final userId = payload['userId'] as String?;

            _viewerChangeController.add(
              LiveViewerChangeEvent(
                streamId: streamId ?? '',
                viewerCount: viewerCount,
                userId: userId,
                isJoin: false,
              ),
            );
          } on Object catch (e) {
            AppLogger.error('Failed to parse viewer_left frame: $e');
          }

        case 'livestream:pinned_comment':
          final commentId = payload['commentId'] as String?;
          _pinnedCommentController.add(commentId);

        case 'livestream:ended':
          try {
            final duration = (payload['duration'] as num?)?.toInt() ?? 0;
            final peakViewers = (payload['peakViewers'] as num?)?.toInt() ?? 0;
            final totalViews = (payload['totalViews'] as num?)?.toInt() ?? 0;
            final totalLikes = (payload['totalLikes'] as num?)?.toInt() ?? 0;
            final recordingUrl = payload['recordingUrl'] as String?;

            _endedController.add(
              LiveEndedEvent(
                streamId: streamId ?? '',
                duration: duration,
                peakViewers: peakViewers,
                totalViews: totalViews,
                totalLikes: totalLikes,
                recordingUrl: recordingUrl,
              ),
            );
          } on Object catch (e) {
            AppLogger.error('Failed to parse livestream:ended frame: $e');
          }

        case 'livestream:started':
          try {
            final stream = LiveStream.fromJson(payload);
            _startedController.add(stream);
          } on Object catch (e) {
            AppLogger.error('Failed to parse livestream:started frame: $e');
          }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _commentController.close();
    _reactionController.close();
    _giftController.close();
    _viewerChangeController.close();
    _pinnedCommentController.close();
    _endedController.close();
    _startedController.close();
  }
}

final liveStreamWsServiceProvider = Provider<LiveStreamWsService>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  final service = LiveStreamWsService(webSocketService: ws);
  ref.onDispose(service.dispose);
  return service;
});
