import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/logging/app_logger.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chat/application/private_chat_providers.dart';
import 'package:lotus_connect/features/chat/domain/usecases/create_private_chat_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/rename_conversation_usecase.dart';

/// UI state for private human-to-human conversation history list.
class PrivateConversationListState {
  const PrivateConversationListState({
    this.conversations = const [],
    this.selectedConversationId,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Conversation> conversations;
  final String? selectedConversationId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  /// Returns only the conversations filtered by title.
  List<Conversation> get filteredConversations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations
        .where((c) => c.title.toLowerCase().contains(query))
        .toList();
  }

  PrivateConversationListState copyWith({
    List<Conversation>? conversations,
    String? selectedConversationId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PrivateConversationListState(
      conversations: conversations ?? this.conversations,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing private conversation list and search state.
class PrivateConversationListNotifier
    extends StateNotifier<PrivateConversationListState> {
  PrivateConversationListNotifier(this._ref)
      : super(const PrivateConversationListState()) {
    _initStream();
  }

  final Ref _ref;

  void _initStream() {
    state = state.copyWith(isLoading: true);
    loadRemoteConversations();
    _ref
        .read(getConversationsUseCaseProvider)(const NoParams())
        .listen((result) {
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (conversations) {
          // Filter to user conversations only
          final userConversations = conversations.where((c) => c.isUserToUser);
          final sorted = List<Conversation>.from(userConversations)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          var currentSelected = state.selectedConversationId;
          if (currentSelected == null && sorted.isNotEmpty) {
            currentSelected = sorted.first.id;
          }

          state = state.copyWith(
            conversations: sorted,
            selectedConversationId: currentSelected,
            isLoading: false,
          );
        },
      );
    });
  }

  /// Syncs remote conversation list from backend server REST API (GET /chats).
  Future<void> loadRemoteConversations() async {
    try {
      final localDataSource = _ref.read(chatCoreLocalDataSourceProvider);

      final getConversationListUseCase =
          _ref.read(getRemoteConversationUseCaseProvider);
      final remoteList = await getConversationListUseCase(const NoParams());

      await remoteList.fold((error) {
        debugPrint('load remote conversations fold - error: ${error.message}');
      }, (conversations) async {
        final existing = await localDataSource.getConversations();
        for (final item in conversations) {
          if (item.id.isNotEmpty) {
            if (!existing.any((c) => c.id == item.id)) {
              await localDataSource.createConversation(
                id: item.id,
                title: item.title,
                isUserToUser: true,
                peerId: item.peerId,
              );
            }
          }
        }
      });
    } on Object catch (e, stackTrace) {
      AppLogger.debug(e.toString(), e, stackTrace);
      // Degrade gracefully if server is offline or endpoint returns empty
    }
  }

  /// Updates search query filter.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Selects active conversation.
  void selectConversation(String conversationId) {
    state = state.copyWith(selectedConversationId: conversationId);
  }

  /// Creates a new private conversation with a friend.
  Future<Conversation?> createNewPrivateChat({
    required String friendId,
    required String title,
  }) async {
    final useCase = _ref.read(createPrivateChatUseCaseProvider);
    final result = await useCase(
      CreatePrivateChatParams(
        friendId: friendId,
        title: title,
      ),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (conversation) {
        selectConversation(conversation.id);
        return conversation;
      },
    );
  }

  Future<void> renameConversation(String id, String newTitle) async {
    await _ref.read(renameConversationUseCaseProvider)(
      RenameConversationParams(conversationId: id, newTitle: newTitle),
    );
  }

  Future<void> deleteConversation(String id) async {
    await _ref.read(deleteConversationUseCaseProvider)(id);
  }

  Future<void> togglePinConversation(String id) async {
    await _ref.read(togglePinConversationUseCaseProvider)(id);
  }

  Future<void> toggleFavouriteConversation(String id) async {
    await _ref.read(toggleFavouriteConversationUseCaseProvider)(id);
  }
}

/// Provider for PrivateConversationListNotifier.
final privateConversationListProvider = StateNotifierProvider<
    PrivateConversationListNotifier, PrivateConversationListState>((ref) {
  return PrivateConversationListNotifier(ref);
});
