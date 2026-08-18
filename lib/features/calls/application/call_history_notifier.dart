import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/calls/application/calls_providers.dart';
import 'package:lotus_connect/features/calls/domain/entities/call_log.dart';
import 'package:lotus_connect/features/calls/domain/usecases/get_call_history_usecase.dart';

/// State holding the call history list.
class CallHistoryState {
  const CallHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<CallLog> history;
  final bool isLoading;
  final String? errorMessage;

  CallHistoryState copyWith({
    List<CallLog>? history,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CallHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier that manages fetching and updating Call History logs.
class CallHistoryNotifier extends StateNotifier<CallHistoryState> {
  CallHistoryNotifier(this._getCallHistoryUseCase)
      : super(const CallHistoryState()) {
    loadCallHistory();
  }

  final GetCallHistoryUseCase _getCallHistoryUseCase;

  /// Loads the call history from gateway.
  Future<void> loadCallHistory() async {
    state = state.copyWith(isLoading: true);
    final result = await _getCallHistoryUseCase(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (logs) => state = state.copyWith(
        history: logs,
        isLoading: false,
      ),
    );
  }
}

/// Global provider for CallHistoryNotifier.
final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, CallHistoryState>((ref) {
  final useCase = ref.watch(getCallHistoryUseCaseProvider);
  return CallHistoryNotifier(useCase);
});
