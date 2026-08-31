import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/contacts_provider.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_friend_requests_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/search_user_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/send_friend_request_usecase.dart';

class ContactsState {
  const ContactsState({
    this.friends = const [],
    this.requests = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<User> friends;
  final List<User> requests;
  final List<User> searchResults;
  final bool isLoading;
  final String? errorMessage;

  ContactsState copyWith({
    List<User>? friends,
    List<User>? requests,
    List<User>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContactsState(
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier({
    required GetContactsUseCase getContactsUseCase,
    required SendFriendRequestUseCase sendFriendRequestUseCase,
    required AcceptFriendRequestUseCase acceptFriendRequestUseCase,
    required RejectFriendRequestUseCase rejectFriendRequestUseCase,
    required GetFriendRequestsUseCase getFriendRequestsUseCase,
    required SearchUserUseCase searchUserUseCase,
  })  : _getContactsUseCase = getContactsUseCase,
        _sendFriendRequestUseCase = sendFriendRequestUseCase,
        _acceptFriendRequestUseCase = acceptFriendRequestUseCase,
        _rejectFriendRequestUseCase = rejectFriendRequestUseCase,
        _getFriendRequestsUseCase = getFriendRequestsUseCase,
        _searchUserUseCase = searchUserUseCase,
        super(const ContactsState()) {
    loadFriends();
  }

  final GetContactsUseCase _getContactsUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase _rejectFriendRequestUseCase;
  final GetFriendRequestsUseCase _getFriendRequestsUseCase;
  final SearchUserUseCase _searchUserUseCase;

  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true);
    try {
      final friendsList = await _getContactsUseCase(const NoParams());

      friendsList.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (friends) {
        debugPrint('check load friend: ${friends.length}');
        state = state.copyWith(
          friends: friends,
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

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: const []);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final results = await _searchUserUseCase(SearchUserParam(query: query));
      results.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (result) {
        state = state.copyWith(searchResults: result, isLoading: false);
      });
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: const []);
  }

  Future<bool> sendFriendRequest(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _sendFriendRequestUseCase(
        SendFriendRequestParam(username: username),
      );
      response.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (success) {
        state = state.copyWith(isLoading: false);
        return true;
      });
      return false;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
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

      await response.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (success) async {
        await loadFriends();
        return true;
      });
      return false;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
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
      await response.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (success) async {
        await loadFriends();
        return true;
      });
      return false;
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }
}

/// Global provider for ContactsNotifier.
final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier(
    getContactsUseCase: ref.watch(getContactsUseCaseProvider),
    sendFriendRequestUseCase: ref.watch(sendFriendRequestUseCaseProvider),
    acceptFriendRequestUseCase: ref.watch(acceptFriendRequestUseCaseProvider),
    rejectFriendRequestUseCase: ref.watch(rejectFriendRequestUseCaseProvider),
    getFriendRequestsUseCase: ref.watch(getFriendRequestsUseCaseProvider),
    searchUserUseCase: ref.watch(searchUserUseCaseProvider),
  );
});
