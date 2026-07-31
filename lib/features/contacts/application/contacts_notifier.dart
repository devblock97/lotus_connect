import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';

/// State representing the Contacts feature status.
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

/// StateNotifier handling contact list fetching, adding friends, and accepting requests.
class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier(this._chatApiService) : super(const ContactsState()) {
    loadFriends();
  }

  final ChatApiService _chatApiService;

  /// Fetches the accepted friends list.
  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true);
    try {
      final friendsList = await _chatApiService.getFriends();
      final requestsList = await _chatApiService.getFriendRequests();
      print('DEBUG: requestsList loaded: ${requestsList.length} items. Contents: ${requestsList.map((e) => e.username).toList()}');
      state = state.copyWith(
        friends: friendsList,
        requests: requestsList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  /// Searches users by username, email, or full name.
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: const []);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final results = await _chatApiService.searchUsers(query);
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
    }
  }

  /// Clears the search results.
  void clearSearch() {
    state = state.copyWith(searchResults: const []);
  }

  /// Sends a new friend request.
  Future<bool> sendFriendRequest(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      await _chatApiService.sendFriendRequest(username);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Accepts a friend request.
  Future<bool> acceptFriendRequest(String friendId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _chatApiService.acceptFriendRequest(friendId);
      await loadFriends(); // Refresh lists
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Rejects a friend request.
  Future<bool> rejectFriendRequest(String friendId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _chatApiService.rejectFriendRequest(friendId);
      await loadFriends(); // Refresh lists
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }
}

/// Global provider for ContactsNotifier.
final contactsProvider = StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final apiService = ref.watch(chatApiServiceProvider);
  return ContactsNotifier(apiService);
});
