import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/data/repositories/chat_core_repository_impl.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/delete_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_conversations_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_messages_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/rename_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/save_draft_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/toggle_favourite_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/toggle_pin_conversation_usecase.dart';

/// Database singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Shared Chat Core Local Data Source provider.
final chatCoreLocalDataSourceProvider =
    Provider<ChatCoreLocalDataSource>((ref) {
  return ChatCoreLocalDataSourceImpl(ref.watch(databaseProvider));
});

/// Shared Chat Core Repository provider.
final chatCoreRepositoryProvider = Provider<ChatCoreRepository>((ref) {
  return ChatCoreRepositoryImpl(ref.watch(chatCoreLocalDataSourceProvider));
});

// Shared Use Cases Providers
final getConversationsUseCaseProvider =
    Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(ref.watch(chatCoreRepositoryProvider));
});

final deleteConversationUseCaseProvider =
    Provider<DeleteConversationUseCase>((ref) {
  return DeleteConversationUseCase(ref.watch(chatCoreRepositoryProvider));
});

final renameConversationUseCaseProvider =
    Provider<RenameConversationUseCase>((ref) {
  return RenameConversationUseCase(ref.watch(chatCoreRepositoryProvider));
});

final togglePinConversationUseCaseProvider =
    Provider<TogglePinConversationUseCase>((ref) {
  return TogglePinConversationUseCase(ref.watch(chatCoreRepositoryProvider));
});

final toggleFavouriteConversationUseCaseProvider =
    Provider<ToggleFavouriteConversationUseCase>((ref) {
  return ToggleFavouriteConversationUseCase(
      ref.watch(chatCoreRepositoryProvider));
});

final saveDraftUseCaseProvider = Provider<SaveDraftUseCase>((ref) {
  return SaveDraftUseCase(ref.watch(chatCoreRepositoryProvider));
});
