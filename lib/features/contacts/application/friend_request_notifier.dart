import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/contacts_provider.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_friend_requests_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';

class FriendRequestState extends Equatable {
  const FriendRequestState({
    this.requests = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.message,
  });

  final List<User> requests;
  final List<User> searchResults;
  final bool isLoading;
  final String? message;

  FriendRequestState copyWith({
    List<User>? requests,
    List<User>? searchResults,
    bool? isLoading,
    String? message,
  }) {
    return FriendRequestState(
      requests: requests ?? this.requests,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        searchResults,
        isLoading,
        message,
      ];
}

class FriendRequestNotifier extends StateNotifier<FriendRequestState> {
  FriendRequestNotifier({
    required GetFriendRequestsUseCase getFriendRequestUseCase,
    required SendFriendRequestUseCase sendFriendRequestUseCase,
    required AcceptFriendRequestUseCase acceptFriendRequestUseCase,
    required RejectFriendRequestUseCase rejectFriendRequestUseCase,
  })  : _getFriendRequestsUseCase = getFriendRequestUseCase,
        _sendFriendRequestUseCase = sendFriendRequestUseCase,
        _acceptFriendRequestUseCase = acceptFriendRequestUseCase,
        _rejectFriendRequestUseCase = rejectFriendRequestUseCase,
        super(const FriendRequestState()) {
    loadFriendRequests();
  }

  final GetFriendRequestsUseCase _getFriendRequestsUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase _rejectFriendRequestUseCase;

  Future<void> loadFriendRequests() async {
    state = state.copyWith(isLoading: true);
    try {
      final friendRequestsList = await _getFriendRequestsUseCase(
        const NoParams(),
      );
      friendRequestsList.fold((error) {
        state = state.copyWith(message: error.message);
      }, (requesters) {
        state = state.copyWith(
          requests: requesters,
          isLoading: false,
        );
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  Future<bool> sendFriendRequest(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _sendFriendRequestUseCase(
        SendFriendRequestParam(username: username),
      );
      response.fold((error) {
        state = state.copyWith(message: error.message);
      }, (success) {
        state = state.copyWith(isLoading: false);
        return true;
      });
      return false;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String friendId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _acceptFriendRequestUseCase(
        AcceptFriendRequestParam(targetId: friendId),
      );
      response.fold((error) {
        state = state.copyWith(message: error.message);
        return false;
      }, (data) async {
        await loadFriendRequests();
        state = state.copyWith(
          isLoading: false,
          message: data.message,
        );
        return data.isSuccess;
      });
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  Future<bool> rejectFriendRequest(String friendId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _rejectFriendRequestUseCase(
        RejectFriendRequestParam(targetId: friendId),
      );
      response.fold((error) {
        state = state.copyWith(message: error.message);
        return false;
      }, (data) async {
        await loadFriendRequests();
        return data.isSuccess;
      });
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }
}

final friendRequestProvider =
    StateNotifierProvider<FriendRequestNotifier, FriendRequestState>((ref) {
  return FriendRequestNotifier(
    getFriendRequestUseCase: ref.watch(getFriendRequestsUseCaseProvider),
    acceptFriendRequestUseCase: ref.watch(acceptFriendRequestUseCaseProvider),
    rejectFriendRequestUseCase: ref.watch(rejectFriendRequestUseCaseProvider),
    sendFriendRequestUseCase: ref.watch(sendFriendRequestUseCaseProvider),
  );
});
