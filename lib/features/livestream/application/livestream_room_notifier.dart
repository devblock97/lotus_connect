import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/features/livestream/application/livestream_providers.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_ws_service.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_comment.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_leaderboard_item.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_viewer.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/end_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_leader_board_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_list_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_list_viewers_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_streams_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/join_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/leave_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/pin_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_comment_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_gift_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/send_reaction_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';
import 'package:lotus_connect/features/settings/application/settings_notifier.dart';

class LiveStreamRoomState {
  const LiveStreamRoomState({
    required this.stream,
    this.comments = const [],
    this.pinnedComment,
    this.viewers = const [],
    this.leaderboard = const [],
    this.activeGift,
    this.reactionBurstTick = 0,
    this.endedEvent,
    this.isLoadingComments = false,
    this.isMuted = false,
    this.isCameraFront = true,
    this.errorMessage,
  });

  final LiveStream stream;
  final List<LiveComment> comments;
  final LiveComment? pinnedComment;
  final List<LiveViewer> viewers;
  final List<LiveLeaderboardItem> leaderboard;
  final LiveGiftEvent? activeGift;
  final int reactionBurstTick;
  final LiveEndedEvent? endedEvent;
  final bool isLoadingComments;
  final bool isMuted;
  final bool isCameraFront;
  final String? errorMessage;

  LiveStreamRoomState copyWith({
    LiveStream? stream,
    List<LiveComment>? comments,
    LiveComment? Function()? pinnedComment,
    List<LiveViewer>? viewers,
    List<LiveLeaderboardItem>? leaderboard,
    LiveGiftEvent? Function()? activeGift,
    int? reactionBurstTick,
    LiveEndedEvent? endedEvent,
    bool? isLoadingComments,
    bool? isMuted,
    bool? isCameraFront,
    String? errorMessage,
  }) {
    return LiveStreamRoomState(
      stream: stream ?? this.stream,
      comments: comments ?? this.comments,
      pinnedComment:
          pinnedComment != null ? pinnedComment() : this.pinnedComment,
      viewers: viewers ?? this.viewers,
      leaderboard: leaderboard ?? this.leaderboard,
      activeGift: activeGift != null ? activeGift() : this.activeGift,
      reactionBurstTick: reactionBurstTick ?? this.reactionBurstTick,
      endedEvent: endedEvent ?? this.endedEvent,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isMuted: isMuted ?? this.isMuted,
      isCameraFront: isCameraFront ?? this.isCameraFront,
      errorMessage: errorMessage,
    );
  }
}

class LiveStreamRoomNotifier extends StateNotifier<LiveStreamRoomState> {
  LiveStreamRoomNotifier({
    required LiveStream initialStream,
    required LiveStreamRepository repository,
    required GetStreamUseCase getStreamUseCase,
    required CreateStreamUseCase createStreamUseCase,
    required StartStreamUseCase startStreamUseCase,
    required EndStreamUseCase endStreamUseCase,
    required SendGiftUseCase sendGiftUseCase,
    required JoinStreamUseCase joinStreamUseCase,
    required LeaveStreamUseCase leaveStreamUseCase,
    required GetListCommentUseCase getListCommentUseCase,
    required GetListViewersUseCase getListViewersUseCase,
    required SendCommentUseCase sendCommentUseCase,
    required PinCommentUseCase pinCommentUseCase,
    required GetLeaderBoardUseCase getLeaderBoardUseCase,
    required SendReactionUseCase sendReactionUseCase,
    required LiveStreamWsService wsService,
    required String currentUserId,
  })  : _repository = repository,
        _getStreamUseCase = getStreamUseCase,
        _createStreamUseCase = createStreamUseCase,
        _startStreamUseCase = startStreamUseCase,
        _endStreamUseCase = endStreamUseCase,
        _sendGiftUseCase = sendGiftUseCase,
        _joinStreamUseCase = joinStreamUseCase,
        _leaveStreamUseCase = leaveStreamUseCase,
        _getListCommentUseCase = getListCommentUseCase,
        _getListViewersUseCase = getListViewersUseCase,
        _sendCommentUseCase = sendCommentUseCase,
        _pinCommentUseCase = pinCommentUseCase,
        _getLeaderBoardUseCase = getLeaderBoardUseCase,
        _sendReactionUseCase = sendReactionUseCase,
        _wsService = wsService,
        _currentUserId = currentUserId,
        super(LiveStreamRoomState(stream: initialStream)) {
    _initRoom();
  }

  final GetStreamUseCase _getStreamUseCase;
  final CreateStreamUseCase _createStreamUseCase;
  final StartStreamUseCase _startStreamUseCase;
  final EndStreamUseCase _endStreamUseCase;
  final SendGiftUseCase _sendGiftUseCase;
  final JoinStreamUseCase _joinStreamUseCase;
  final LeaveStreamUseCase _leaveStreamUseCase;
  final GetListCommentUseCase _getListCommentUseCase;
  final GetListViewersUseCase _getListViewersUseCase;
  final SendCommentUseCase _sendCommentUseCase;
  final PinCommentUseCase _pinCommentUseCase;
  final GetLeaderBoardUseCase _getLeaderBoardUseCase;
  final SendReactionUseCase _sendReactionUseCase;
  final LiveStreamRepository _repository;
  final LiveStreamWsService _wsService;
  final String _currentUserId;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _giftDismissTimer;

  String get currentUserId => _currentUserId;
  bool get isHost =>
      state.stream.isHost ||
      (state.stream.host.id.isNotEmpty &&
          _currentUserId.isNotEmpty &&
          state.stream.host.id == _currentUserId);

  Future<void> _initRoom() async {
    final streamId = state.stream.id;

    // Join room via WS
    _wsService.joinRoom(streamId);

    // Call REST join if viewer
    if (!isHost) {
      try {
        await _joinStreamUseCase(JoinStreamParam(streamId: streamId));
      } on Object catch (e) {
        AppLogger.warning('Join stream REST non-fatal error: $e');
      }
    }

    _subscribeWsEvents();

    // Load initial comments, viewers, leaderboard
    await Future.wait([
      _loadComments(),
      _loadViewers(),
      _loadLeaderboard(),
      _loadLatestDetails(),
    ]);
  }

  void _subscribeWsEvents() {
    _subscriptions.add(
      _wsService.commentStream.listen((comment) {
        final updated = List<LiveComment>.from(state.comments)..add(comment);
        // Keep max 100 comments in memory
        if (updated.length > 100) {
          updated.removeAt(0);
        }
        state = state.copyWith(comments: updated);
      }),
    );

    _subscriptions.add(
      _wsService.reactionStream.listen((reactionEvent) {
        final updatedStream = state.stream.copyWith(
          likeCount: reactionEvent.totalLikes > 0
              ? reactionEvent.totalLikes
              : state.stream.likeCount + reactionEvent.count,
        );
        state = state.copyWith(
          stream: updatedStream,
          reactionBurstTick: state.reactionBurstTick + 1,
        );
      }),
    );

    _subscriptions.add(
      _wsService.giftStream.listen((giftEvent) {
        _giftDismissTimer?.cancel();
        state = state.copyWith(
          activeGift: () => giftEvent,
          reactionBurstTick: state.reactionBurstTick + 2,
        );

        final systemComment = LiveComment(
          id: 'gift-${giftEvent.id}',
          streamId: giftEvent.streamId,
          user: giftEvent.sender,
          content: 'sent '
              '${giftEvent.giftCount > 1 ? "${giftEvent.giftCount}x " : ""}'
              '${giftEvent.giftDefinition.name} '
              '${giftEvent.giftDefinition.icon}',
          isSystem: true,
          createdAt: giftEvent.createdAt,
        );
        final updatedComments = List<LiveComment>.from(state.comments)
          ..add(systemComment);

        state = state.copyWith(comments: updatedComments);

        _giftDismissTimer = Timer(const Duration(milliseconds: 4500), () {
          if (mounted) {
            state = state.copyWith(activeGift: () => null);
          }
        });

        // Refresh leaderboard
        _loadLeaderboard();
      }),
    );

    _subscriptions.add(
      _wsService.viewerChangeStream.listen((viewerEvent) {
        final updatedStream = state.stream.copyWith(
          viewerCount: viewerEvent.viewerCount,
        );

        var updatedComments = state.comments;
        if (viewerEvent.isJoin && viewerEvent.user != null) {
          final joinComment = LiveComment(
            id: 'join-${DateTime.now().millisecondsSinceEpoch}',
            streamId: viewerEvent.streamId,
            user: viewerEvent.user!,
            content: 'joined the live room',
            isSystem: true,
            createdAt: DateTime.now(),
          );
          updatedComments = List<LiveComment>.from(state.comments)
            ..add(joinComment);
        }

        state = state.copyWith(
          stream: updatedStream,
          comments: updatedComments,
        );

        _loadViewers();
      }),
    );

    _subscriptions.add(
      _wsService.pinnedCommentStream.listen((commentId) {
        if (commentId == null || commentId.isEmpty) {
          state = state.copyWith(pinnedComment: () => null);
        } else {
          final target = state.comments.cast<LiveComment?>().firstWhere(
                (c) => c?.id == commentId,
                orElse: () => null,
              );
          if (target != null) {
            state = state.copyWith(pinnedComment: () => target);
          }
        }
      }),
    );

    _subscriptions.add(
      _wsService.endedStream.listen((endedEvent) {
        final updatedStream = state.stream.copyWith(
          status: 'ended',
          endedAt: DateTime.now(),
          durationSeconds: endedEvent.duration,
          peakViewers: endedEvent.peakViewers,
          totalViews: endedEvent.totalViews,
          likeCount: endedEvent.totalLikes,
          recordingUrl: endedEvent.recordingUrl,
        );
        state = state.copyWith(
          stream: updatedStream,
          endedEvent: endedEvent,
        );
      }),
    );
  }

  Future<LiveStream?> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    final result = await _createStreamUseCase(
      CreateStreamParam(
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl,
        privacy: privacy,
      ),
    );

    return result.fold(
      (error) {
        state = state.copyWith(errorMessage: error.message);
        return null;
      },
      (success) => success,
    );
  }

  Future<void> _loadLatestDetails() async {
    try {
      final result = await _getStreamUseCase(
        GetStreamParam(streamId: state.stream.id),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (latest) {
        final isStreamHost = latest.isHost ||
            state.stream.isHost ||
            (latest.host.id.isNotEmpty && latest.host.id == _currentUserId);
        final streamWithHost = latest.copyWith(isHost: isStreamHost);
        LiveComment? pinned;
        if (latest.pinnedCommentId != null) {
          pinned = state.comments.cast<LiveComment?>().firstWhere(
                (c) => c?.id == latest.pinnedCommentId,
                orElse: () => null,
              );
        }
        if (latest.isEnded) {
          state = state.copyWith(
            stream: streamWithHost,
            pinnedComment: pinned != null ? () => pinned : null,
            endedEvent: LiveEndedEvent(
              streamId: latest.id,
              duration: latest.durationSeconds,
              peakViewers: latest.peakViewers,
              totalViews: latest.totalViews,
              totalLikes: latest.likeCount,
              recordingUrl: latest.recordingUrl,
            ),
          );
        } else {
          state = state.copyWith(
            stream: streamWithHost,
            pinnedComment: pinned != null ? () => pinned : null,
          );
        }
      });
    } on Object catch (e) {
      AppLogger.warning('Failed to load latest stream details: $e');
    }
  }

  Future<void> _loadComments() async {
    state = state.copyWith(isLoadingComments: true);
    try {
      final result = await _getListCommentUseCase(
        GetListCommentParam(streamId: state.stream.id, limit: 50),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (comments) {
        state = state.copyWith(
          comments: comments,
          isLoadingComments: false,
        );
      });
    } on Object catch (e) {
      AppLogger.warning('Failed to fetch initial comments: $e');
      state = state.copyWith(isLoadingComments: false);
    }
  }

  Future<void> _loadViewers() async {
    try {
      final result = await _getListViewersUseCase(
        GetListViewersParam(streamId: state.stream.id, limit: 15),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (viewers) {
        state = state.copyWith(viewers: viewers);
      });
    } on Object catch (e) {
      AppLogger.warning('Failed to fetch live viewers: $e');
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final result = await _getLeaderBoardUseCase(
        GetLeaderBoardParam(streamId: state.stream.id),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (leaderboard) {
        state = state.copyWith(leaderboard: leaderboard);
      });
    } on Object catch (e) {
      AppLogger.warning('Failed to load gift leaderboard: $e');
    }
  }

  Future<void> sendComment(String content) async {
    if (content.trim().isEmpty) return;
    try {
      final result = await _sendCommentUseCase(
        SendCommentParam(streamId: state.stream.id, content: content),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (created) {
        final updated = List<LiveComment>.from(state.comments)..add(created);
        state = state.copyWith(comments: updated);
      });
    } on Object catch (e) {
      AppLogger.error('Failed to send comment: $e');
    }
  }

  Future<void> sendReactionBurst({
    String reaction = 'heart',
    int count = 1,
  }) async {
    // Immediate UI feedback
    state = state.copyWith(
      reactionBurstTick: state.reactionBurstTick + 1,
      stream: state.stream.copyWith(likeCount: state.stream.likeCount + count),
    );

    try {
      final result = await _sendReactionUseCase(
        SendReactionParam(
          streamId: state.stream.id,
          reaction: reaction,
          count: count,
        ),
      );
      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (totalLikes) {
        if (totalLikes > 0) {
          state = state.copyWith(
            stream: state.stream.copyWith(likeCount: totalLikes),
          );
        }
      });
    } on Object catch (e) {
      AppLogger.warning('Failed to send reaction burst: $e');
    }
  }

  Future<void> sendGift(String giftType, int count) async {
    try {
      final result = await _sendGiftUseCase(
        SendGiftParam(
          streamId: state.stream.id,
          reaction: giftType,
          count: count,
        ),
      );

      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (giftEvent) {
        // Trigger animation locally if server doesn't echo back fast
        _giftDismissTimer?.cancel();
        state = state.copyWith(
          activeGift: () => giftEvent,
          reactionBurstTick: state.reactionBurstTick + 3,
        );
        _giftDismissTimer = Timer(const Duration(milliseconds: 4500), () {
          if (mounted) {
            state = state.copyWith(activeGift: () => null);
          }
        });
        unawaited(_loadLeaderboard());
      });
    } on Object catch (e) {
      AppLogger.error('Failed to send gift: $e');
      state = state.copyWith(errorMessage: 'Failed to send gift');
    }
  }

  Future<void> pinComment(LiveComment comment) async {
    if (!isHost) return;
    try {
      final result = await _pinCommentUseCase(
        PinCommentParam(streamId: state.stream.id, commentId: comment.id),
      );
      result.fold((error) {}, (success) {
        state = state.copyWith(pinnedComment: () => comment);
      });
    } on Object catch (e) {
      AppLogger.error('Failed to pin comment: $e');
    }
  }

  Future<void> unpinComment() async {
    if (!isHost || state.pinnedComment == null) return;
    try {
      await _repository.unpinComment(state.stream.id, state.pinnedComment!.id);
      state = state.copyWith(pinnedComment: () => null);
    } on Object catch (e) {
      AppLogger.error('Failed to unpin comment: $e');
    }
  }

  Future<void> startStream() async {
    if (!isHost) return;
    try {
      final result = await _startStreamUseCase(
        StartStreamParam(streamId: state.stream.id),
      );
      result.fold(
        (error) {
          state = state.copyWith(errorMessage: error.message);
        },
        (updated) {
          state = state.copyWith(stream: updated);
        },
      );
    } on Object catch (e) {
      AppLogger.error('Failed to start stream: $e');
      state = state.copyWith(errorMessage: 'Failed to go live: $e');
    }
  }

  Future<void> endStream({String? recordingUrl}) async {
    if (!isHost) return;
    try {
      final result = await _endStreamUseCase(
        EndStreamParam(
          streamId: state.stream.id,
          recordingUrl: recordingUrl,
        ),
      );

      result.fold((error) {
        state = state.copyWith(
          errorMessage: error.message,
        );
      }, (updated) {
        state = state.copyWith(
          stream: updated,
          endedEvent: LiveEndedEvent(
            streamId: updated.id,
            duration: updated.durationSeconds,
            peakViewers: updated.peakViewers,
            totalViews: updated.totalViews,
            totalLikes: updated.likeCount,
            recordingUrl: updated.recordingUrl,
          ),
        );
      });
    } on Object catch (e) {
      AppLogger.error('Failed to end stream: $e');
    }
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleCamera() {
    state = state.copyWith(isCameraFront: !state.isCameraFront);
  }

  Future<void> leave() async {
    _wsService.leaveRoom(state.stream.id);
    if (!isHost) {
      try {
        await _leaveStreamUseCase(
          LeaveStreamParam(streamId: state.stream.id),
        );
      } on Object catch (_) {}
    }
  }

  @override
  void dispose() {
    _giftDismissTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    unawaited(leave());
    super.dispose();
  }
}

final liveStreamRoomProvider = StateNotifierProvider.autoDispose
    .family<LiveStreamRoomNotifier, LiveStreamRoomState, LiveStream>(
  (ref, stream) {
    final repository = ref.watch(liveStreamRepositoryProvider);
    final getStreamUseCase = ref.watch(getStreamUseCaseProvider);
    final createStreamUseCase = ref.watch(createStreamUseCaseProvider);
    final startStreamUseCase = ref.watch(startStreamUseCaseProvider);
    final endStreamUseCase = ref.watch(endStreamUseCaseProvider);
    final sendGiftUseCase = ref.watch(sendGiftUseCaseProvider);
    final joinStreamUseCase = ref.watch(joinStreamUseCaseProvider);
    final leaveStreamUseCase = ref.watch(leaveStreamUseCaseProvider);
    final getListCommentUseCase = ref.watch(getListCommentUseCaseProvider);
    final getListViewersUseCase = ref.watch(getListViewersUseCaseProvider);
    final sendCommentUseCase = ref.watch(sendCommentUseCaseProvider);
    final pinCommentUseCase = ref.watch(pinCommentUseCaseProvider);
    final getLeaderBoardUseCase = ref.watch(getLeaderBoardUseCaseProvider);
    final sendReactionUseCase = ref.watch(sendReactionUseCaseProvider);
    final wsService = ref.watch(liveStreamWsServiceProvider);
    final currentUserId = ref.watch(settingsNotifierProvider).settings.userId;

    return LiveStreamRoomNotifier(
      initialStream: stream,
      repository: repository,
      getStreamUseCase: getStreamUseCase,
      createStreamUseCase: createStreamUseCase,
      startStreamUseCase: startStreamUseCase,
      endStreamUseCase: endStreamUseCase,
      sendGiftUseCase: sendGiftUseCase,
      joinStreamUseCase: joinStreamUseCase,
      leaveStreamUseCase: leaveStreamUseCase,
      getListCommentUseCase: getListCommentUseCase,
      getListViewersUseCase: getListViewersUseCase,
      sendCommentUseCase: sendCommentUseCase,
      pinCommentUseCase: pinCommentUseCase,
      getLeaderBoardUseCase: getLeaderBoardUseCase,
      sendReactionUseCase: sendReactionUseCase,
      wsService: wsService,
      currentUserId: currentUserId,
    );
  },
);
