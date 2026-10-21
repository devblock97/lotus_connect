import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/features/livestream/application/livestream_providers.dart';
import 'package:lotus_connect/features/livestream/data/datasources/livestream_ws_service.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/get_list_stream_use_case.dart';

class LiveStreamFeedState {
  const LiveStreamFeedState({
    this.isLoading = false,
    this.streams = const [],
    this.statusFilter = 'live',
    this.errorMessage,
  });

  final bool isLoading;
  final List<LiveStream> streams;
  final String statusFilter;
  final String? errorMessage;

  LiveStreamFeedState copyWith({
    bool? isLoading,
    List<LiveStream>? streams,
    String? statusFilter,
    String? errorMessage,
  }) {
    return LiveStreamFeedState(
      isLoading: isLoading ?? this.isLoading,
      streams: streams ?? this.streams,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage,
    );
  }
}

class LiveStreamFeedNotifier extends StateNotifier<LiveStreamFeedState> {
  LiveStreamFeedNotifier({
    required LiveStreamRepository repository,
    required GetListStreamUseCase getListStreamUseCase,
    LiveStreamWsService? wsService,
  })  : _repository = repository,
        _wsService = wsService,
        _getListStreamUseCase = getListStreamUseCase,
        super(const LiveStreamFeedState()) {
    _init();
  }

  final LiveStreamRepository _repository;
  final LiveStreamWsService? _wsService;
  final GetListStreamUseCase _getListStreamUseCase;
  StreamSubscription<LiveEndedEvent>? _endedSub;
  StreamSubscription<LiveStream>? _startedSub;
  Timer? _periodicRefreshTimer;

  void _init() {
    fetchStreams();
    _subscribeWsEvents();
    _startPeriodicRefresh();
  }

  void _subscribeWsEvents() {
    if (_wsService != null) {
      _endedSub = _wsService.endedStream.listen((endedEvent) {
        removeStream(endedEvent.streamId);
      });
      _startedSub = _wsService.startedStream.listen(upsertStream);
    }
  }

  void _startPeriodicRefresh() {
    // Sync active streams periodically to keep stories tray up-to-date
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchStreams();
    });
  }

  void removeStream(String streamId) {
    if (streamId.isEmpty) return;
    final updated = state.streams.where((s) => s.id != streamId).toList();
    if (updated.length != state.streams.length) {
      state = state.copyWith(streams: updated);
    }
  }

  void upsertStream(LiveStream stream) {
    if (stream.isLive) {
      final index = state.streams.indexWhere((s) => s.id == stream.id);
      if (index >= 0) {
        final updated = List<LiveStream>.from(state.streams);
        updated[index] = stream;
        state = state.copyWith(streams: updated);
      } else {
        state = state.copyWith(streams: [stream, ...state.streams]);
      }
    } else {
      removeStream(stream.id);
    }
  }

  Future<void> fetchStreams({String? status}) async {
    final filter = status ?? state.statusFilter;
    state = state.copyWith(
      isLoading: true,
      statusFilter: filter,
    );

    try {
      final result = await _getListStreamUseCase(
        ListStreamParam(status: filter),
      );

      result.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (streams) {
        state = state.copyWith(
          isLoading: false,
          streams: streams,
        );
      });
    } on Object catch (e, st) {
      AppLogger.error('Failed to load livestream feed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => fetchStreams();

  void changeStatusFilter(String newFilter) {
    if (state.statusFilter == newFilter) return;
    fetchStreams(status: newFilter);
  }

  @override
  void dispose() {
    _endedSub?.cancel();
    _startedSub?.cancel();
    _periodicRefreshTimer?.cancel();
    super.dispose();
  }
}

final liveStreamFeedProvider =
    StateNotifierProvider<LiveStreamFeedNotifier, LiveStreamFeedState>((ref) {
  final repository = ref.watch(liveStreamRepositoryProvider);
  final wsService = ref.watch(liveStreamWsServiceProvider);
  final listStreamUseCase = GetListStreamUseCase(repository);
  return LiveStreamFeedNotifier(
    repository: repository,
    wsService: wsService,
    getListStreamUseCase: listStreamUseCase,
  );
});
