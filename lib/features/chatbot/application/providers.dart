import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/services/ai/ai_provider.dart';
import 'package:lotus_connect/core/services/ai/gemini_ai_provider.dart';
import 'package:lotus_connect/core/services/ai/local_ai_provider.dart';
import 'package:lotus_connect/core/services/ai/mock_ai_provider.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_local_data_source.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:lotus_connect/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/create_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/delete_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/get_conversations_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/rename_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/save_draft_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/stream_ai_response_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/toggle_favourite_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/toggle_pin_conversation_usecase.dart';

/// Database singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Dio client provider.
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

/// Current active AI Provider dynamically bound to user settings.
final activeAiProvider = Provider<AiProvider>((ref) {
  final settings = ref.watch(settingsProvider);
  final dioClient = ref.watch(dioClientProvider);

  if (settings.activeAiProvider == 'gemini') {
    return GeminiAiProvider(
      dioClient: dioClient,
      apiKey: settings.geminiApiKey,
    );
  } else if (settings.activeAiProvider == 'local') {
    return LocalAiProvider(
      dioClient: dioClient,
      baseUrl: settings.localLlmBaseUrl,
    );
  }
  return MockAiProvider();
});

/// Local Data Source provider.
final chatbotLocalDataSourceProvider = Provider<ChatbotLocalDataSource>((ref) {
  return ChatbotLocalDataSourceImpl(ref.watch(databaseProvider));
});

/// Remote Data Source provider.
final chatbotRemoteDataSourceProvider =
    Provider<ChatbotRemoteDataSource>((ref) {
  final provider = ref.watch(activeAiProvider);
  return ChatbotRemoteDataSourceImpl(provider);
});

/// Chatbot Repository provider.
final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotRepositoryImpl(
    localDataSource: ref.watch(chatbotLocalDataSourceProvider),
    remoteDataSource: ref.watch(chatbotRemoteDataSourceProvider),
  );
});

// Use Cases Providers
final getConversationsUseCaseProvider =
    Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(ref.watch(chatbotRepositoryProvider));
});

final createConversationUseCaseProvider =
    Provider<CreateConversationUseCase>((ref) {
  return CreateConversationUseCase(ref.watch(chatbotRepositoryProvider));
});

final deleteConversationUseCaseProvider =
    Provider<DeleteConversationUseCase>((ref) {
  return DeleteConversationUseCase(ref.watch(chatbotRepositoryProvider));
});

final renameConversationUseCaseProvider =
    Provider<RenameConversationUseCase>((ref) {
  return RenameConversationUseCase(ref.watch(chatbotRepositoryProvider));
});

final togglePinConversationUseCaseProvider =
    Provider<TogglePinConversationUseCase>((ref) {
  return TogglePinConversationUseCase(ref.watch(chatbotRepositoryProvider));
});

final toggleFavouriteConversationUseCaseProvider =
    Provider<ToggleFavouriteConversationUseCase>((ref) {
  return ToggleFavouriteConversationUseCase(
      ref.watch(chatbotRepositoryProvider));
});

final saveDraftUseCaseProvider = Provider<SaveDraftUseCase>((ref) {
  return SaveDraftUseCase(ref.watch(chatbotRepositoryProvider));
});

final streamAiResponseUseCaseProvider =
    Provider<StreamAiResponseUseCase>((ref) {
  return StreamAiResponseUseCase(ref.watch(chatbotRepositoryProvider));
});
