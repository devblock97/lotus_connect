import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/create_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/rename_conversation_usecase.dart';

class ConversationListState {
  const ConversationListState({
    this.conversations = const [],
    this.searchQuery = '',
    this.selectedConversationId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Conversation> conversations;
  final String searchQuery;
  final String? selectedConversationId;
  final bool isLoading;
  final String? errorMessage;

  /// Returns filtered list based on [searchQuery].
  List<Conversation> get filteredConversations {
    if (searchQuery.trim().isEmpty) return conversations;
    final query = searchQuery.toLowerCase();
    return conversations
        .where((c) => c.title.toLowerCase().contains(query))
        .toList();
  }

  List<Conversation> get pinnedConversations =>
      filteredConversations.where((c) => c.isPinned).toList();

  List<Conversation> get unpinnedConversations =>
      filteredConversations.where((c) => !c.isPinned).toList();

  ConversationListState copyWith({
    List<Conversation>? conversations,
    String? searchQuery,
    String? selectedConversationId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing conversation list state.
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  ConversationListNotifier(this._ref) : super(const ConversationListState()) {
    _initStream();
  }

  final Ref _ref;

  void _initStream() {
    state = state.copyWith(isLoading: true);
    final getConversations = _ref.read(getConversationsUseCaseProvider);
    getConversations(const NoParams()).listen((result) {
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (conversations) {
          final sorted = List<Conversation>.from(conversations)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          String? currentSelected = state.selectedConversationId;
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

  /// Creates a new conversation.
  Future<Conversation?> createNewConversation({
    String title = 'New Conversation',
    String? modelName,
  }) async {
    final createUseCase = _ref.read(createConversationUseCaseProvider);
    final result = await createUseCase(
      CreateConversationParams(title: title, modelName: modelName),
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
    final renameUseCase = _ref.read(renameConversationUseCaseProvider);
    await renameUseCase(
      RenameConversationParams(conversationId: id, newTitle: newTitle),
    );
  }

  Future<void> deleteConversation(String id) async {
    final deleteUseCase = _ref.read(deleteConversationUseCaseProvider);
    await deleteUseCase(id);
    if (state.selectedConversationId == id) {
      final remaining = state.conversations.where((c) => c.id != id).toList();
      state = state.copyWith(
        selectedConversationId:
            remaining.isNotEmpty ? remaining.first.id : null,
      );
    }
  }

  Future<void> togglePin(String id) async {
    final togglePinUseCase = _ref.read(togglePinConversationUseCaseProvider);
    await togglePinUseCase(id);
  }

  Future<void> toggleFavourite(String id) async {
    final toggleFavUseCase =
        _ref.read(toggleFavouriteConversationUseCaseProvider);
    await toggleFavUseCase(id);
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
        (ref) {
  return ConversationListNotifier(ref);
});
