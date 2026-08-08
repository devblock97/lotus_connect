import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/rename_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/create_conversation_usecase.dart';

/// UI state for conversation history list.
class ConversationListState {
  const ConversationListState({
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

  /// Returns only the conversations matching the search query filter.
  List<Conversation> get filteredConversations {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations
        .where((c) => c.title.toLowerCase().contains(query))
        .toList();
  }

  ConversationListState copyWith({
    List<Conversation>? conversations,
    String? selectedConversationId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing AI chatbot conversation lists and search state.
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  ConversationListNotifier(this._ref) : super(const ConversationListState()) {
    _initStream();
  }

  final Ref _ref;

  void _initStream() {
    state = state.copyWith(isLoading: true);
    _ref
        .read(getConversationsUseCaseProvider)(const NoParams())
        .listen((result) {
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (conversations) {
          // Filter to AI conversations only
          final aiConversations = conversations.where((c) => !c.isUserToUser);
          final sorted = List<Conversation>.from(aiConversations)
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

  /// Updates search query filter.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Selects active conversation.
  void selectConversation(String conversationId) {
    state = state.copyWith(selectedConversationId: conversationId);
  }

  /// Creates a new AI conversation.
  Future<Conversation?> createNewConversation({
    String title = 'New Conversation',
    String? modelName,
  }) async {
    final createUseCase = _ref.read(createConversationUseCaseProvider);
    final result = await createUseCase(
      CreateConversationParams(title: title, modelName: modelName),
    );
    return result.fold<Conversation?>(
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

/// Provider for ConversationListNotifier.
final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
        (ref) {
  return ConversationListNotifier(ref);
});
