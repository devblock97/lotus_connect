import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/livestream/application/livestream_providers.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/create_stream_use_case.dart';
import 'package:lotus_connect/features/livestream/domain/usecases/start_stream_use_case.dart';

class GoLiveState extends Equatable {
  const GoLiveState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final String? error;

  GoLiveState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GoLiveState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}

class GoLiveNotifier extends StateNotifier<GoLiveState> {
  GoLiveNotifier({
    required CreateStreamUseCase createStreamUseCase,
    required StartStreamUseCase startStreamUseCase,
  })  : _createStreamUseCase = createStreamUseCase,
        _startStreamUseCase = startStreamUseCase,
        super(const GoLiveState());

  final CreateStreamUseCase _createStreamUseCase;
  final StartStreamUseCase _startStreamUseCase;

  Future<LiveStream?> createStream({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    if (mounted) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final result = await _createStreamUseCase(
        CreateStreamParam(
          title: title,
          description: description,
          thumbnailUrl: thumbnailUrl,
          privacy: privacy,
        ),
      );

      if (!mounted) return null;

      final response = result.fold<LiveStream?>(
        (failure) {
          if (mounted) {
            state = state.copyWith(isLoading: false, error: failure.message);
          }
          return null;
        },
        (stream) {
          if (mounted) {
            state = state.copyWith(isLoading: false);
          }
          return stream;
        },
      );
      return response;
    } on Object catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return null;
    }
  }

  Future<LiveStream?> startStream(String streamId) async {
    if (mounted) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final result = await _startStreamUseCase(
        StartStreamParam(streamId: streamId),
      );

      if (!mounted) return null;

      final response = result.fold<LiveStream?>(
        (failure) {
          if (mounted) {
            state = state.copyWith(isLoading: false, error: failure.message);
          }
          return null;
        },
        (stream) {
          if (mounted) {
            state = state.copyWith(isLoading: false);
          }
          return stream;
        },
      );
      return response;
    } on Object catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return null;
    }
  }

  Future<LiveStream?> goLive({
    required String title,
    String? description,
    String? thumbnailUrl,
    String? privacy,
  }) async {
    final stream = await createStream(
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      privacy: privacy,
    );
    if (stream == null || !mounted) return null;

    return startStream(stream.id);
  }
}

final goLiveNotifierProvider =
    StateNotifierProvider.autoDispose<GoLiveNotifier, GoLiveState>((ref) {
  final createStreamUseCase = ref.watch(createStreamUseCaseProvider);
  final startStreamUseCase = ref.watch(startStreamUseCaseProvider);
  return GoLiveNotifier(
    createStreamUseCase: createStreamUseCase,
    startStreamUseCase: startStreamUseCase,
  );
});
