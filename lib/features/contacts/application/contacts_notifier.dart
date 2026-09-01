import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/contacts/application/contacts_provider.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/delete_friend_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/get_contacts_usecase.dart';
import 'package:lotus_connect/features/contacts/domain/usecases/search_user_usecase.dart';

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
    required SearchUserUseCase searchUserUseCase,
    required DeleteFriendUseCase deleteFriendUseCase,
  })  : _getContactsUseCase = getContactsUseCase,
        _searchUserUseCase = searchUserUseCase,
        _deleteFriendUseCase = deleteFriendUseCase,
        super(const ContactsState()) {
    loadFriends();
  }

  final GetContactsUseCase _getContactsUseCase;
  final SearchUserUseCase _searchUserUseCase;
  final DeleteFriendUseCase _deleteFriendUseCase;

  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true);
    try {
      final friendsList = await _getContactsUseCase(const NoParams());

      friendsList.fold((error) {
        state = state.copyWith(errorMessage: error.message);
      }, (friends) {
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

  Future<bool> deleteFriend(String friendId) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _deleteFriendUseCase(
        DeleteFriendParam(friendId: friendId),
      );
      return result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.message,
          );
          return false;
        },
        (_) {
          final updatedFriends =
              state.friends.where((friend) => friend.id != friendId).toList();
          state = state.copyWith(
            friends: updatedFriends,
            isLoading: false,
          );
          return true;
        },
      );
    } on Object catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
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
}

/// Global provider for ContactsNotifier.
final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier(
    getContactsUseCase: ref.watch(getContactsUseCaseProvider),
    searchUserUseCase: ref.watch(searchUserUseCaseProvider),
    deleteFriendUseCase: ref.watch(deleteFriendUseCaseProvider),
  );
});
