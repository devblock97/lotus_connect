import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/contacts_provider.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_friend_requests_usecase.dart';

class FriendRequestState {
  const FriendRequestState({
    this.requests = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<User> requests;
  final List<User> searchResults;
  final bool isLoading;
  final String? errorMessage;

  FriendRequestState copyWith({
    List<User>? requests,
    List<User>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FriendRequestState(
      requests: requests ?? this.requests,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FriendRequestNotifier extends StateNotifier<FriendRequestState> {
  FriendRequestNotifier({
    required GetFriendRequestsUseCase getFriendRequestUseCase,
  })  : _getFriendRequestsUseCase = getFriendRequestUseCase,
        super(const FriendRequestState()) {
    loadFriendRequests();
  }

  final GetFriendRequestsUseCase _getFriendRequestsUseCase;

  Future<void> loadFriendRequests() async {
    state = state.copyWith(isLoading: true);
    try {
      final friendRequestsList = await _getFriendRequestsUseCase(
        const NoParams(),
      );
      friendRequestsList.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (requesters) {
        state = state.copyWith(
          requests: requesters,
          isLoading: false,
        );
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }
}

final friendRequestProvider =
    StateNotifierProvider<FriendRequestNotifier, FriendRequestState>((ref) {
  return FriendRequestNotifier(
    getFriendRequestUseCase: ref.watch(getFriendRequestsUseCaseProvider),
  );
});
