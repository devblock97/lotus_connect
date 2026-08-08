import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';

/// Client-side model representing a call record log.
class CallLog {
  const CallLog({
    required this.id,
    required this.hostId,
    required this.channelId,
    required this.isVideo,
    required this.status,
    required this.createdAt,
    this.conversationId,
    this.endedAt,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? json['host_id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ??
          json['conversation_id'] as String?,
      channelId:
          json['channelId'] as String? ?? json['channel_id'] as String? ?? '',
      isVideo: json['isVideo'] as bool? ?? json['is_video'] as bool? ?? false,
      status: json['status'] as String? ?? 'initiated',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String) ??
                  DateTime.now()
              : DateTime.now(),
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'] as String)
          : json['ended_at'] != null
              ? DateTime.tryParse(json['ended_at'] as String)
              : null,
    );
  }

  final String id;
  final String hostId;
  final String? conversationId;
  final String channelId;
  final bool isVideo;
  final String status;
  final DateTime createdAt;
  final DateTime? endedAt;

  int get durationSeconds {
    if (endedAt == null) return 0;
    return endedAt!.difference(createdAt).inSeconds;
  }
}

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

/// Notifier that manages fetching and updating Call History log files.
class CallHistoryNotifier extends StateNotifier<CallHistoryState> {
  CallHistoryNotifier(this._chatApiService) : super(const CallHistoryState()) {
    loadCallHistory();
  }

  final ChatApiService _chatApiService;

  /// Loads the call history from the gateway endpoint.
  Future<void> loadCallHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _chatApiService.getCallHistory();
      final callLogs = list.map(CallLog.fromJson).toList();
      state = state.copyWith(history: callLogs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }
}

/// Global provider for CallHistoryNotifier.
final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, CallHistoryState>((ref) {
  final apiService = ref.watch(chatApiServiceProvider);
  return CallHistoryNotifier(apiService);
});
