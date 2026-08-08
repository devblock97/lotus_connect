import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/core/services/ai/ai_provider.dart';
import 'package:lotus_connect/core/services/ai/gemini_ai_provider.dart';
import 'package:lotus_connect/core/services/ai/local_ai_provider.dart';
import 'package:lotus_connect/core/services/ai/mock_ai_provider.dart';
import 'package:lotus_connect/core/services/webrtc/signaling_service.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chatbot/application/settings_notifier.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_local_data_source.dart';
import 'package:lotus_connect/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:lotus_connect/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/create_conversation_usecase.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/stream_ai_response_usecase.dart';

/// Dio client provider configured dynamically with user settings and RTR support.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    tokenGetter: () => ref.read(settingsProvider).accessToken,
    serverHostGetter: () => ref.read(settingsProvider).serverHost,
    refreshTokenGetter: () => ref.read(settingsProvider).refreshToken,
    onTokensRefreshed: (accessToken, refreshToken) async {
      await ref
          .read(settingsProvider.notifier)
          .setTokens(accessToken, refreshToken);
    },
    onRefreshFailed: () {
      ref.read(settingsProvider.notifier).clearTokens();
    },
  );
});

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
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
  );
});

// Use Cases Providers
final createConversationUseCaseProvider =
    Provider<CreateConversationUseCase>((ref) {
  return CreateConversationUseCase(ref.watch(chatbotRepositoryProvider));
});

final streamAiResponseUseCaseProvider =
    Provider<StreamAiResponseUseCase>((ref) {
  return StreamAiResponseUseCase(ref.watch(chatbotRepositoryProvider));
});

/// StateProvider managing the active tab index inside MainShellScreen.
final shellIndexProvider = StateProvider<int>((ref) => 0);

/// Data model representing a request to start a call from other screens.
class CallRequest {
  const CallRequest({required this.recipientId, required this.isVideo});
  final String recipientId;
  final bool isVideo;
}

/// Global provider for cross-screen call requests.
final callRequestProvider = StateProvider<CallRequest?>((ref) => null);

/// StreamProvider yielding incoming call invitations.
final incomingCallProvider = StreamProvider<WebRTCCallInvitation>((ref) {
  final signaling = ref.watch(webrtcSignalingServiceProvider);
  return signaling.invitationStream;
});
