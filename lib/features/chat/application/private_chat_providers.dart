import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_local_data_source.dart';
import 'package:lotus_connect/features/chat/data/datasources/private_chat_remote_data_source.dart';
import 'package:lotus_connect/features/chat/data/repositories/private_chat_repository_impl.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/create_private_chat_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_conversation_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chatbot/application/providers.dart';

/// Provider for PrivateChatRemoteDataSource.
final privateChatRemoteDataSourceProvider =
    Provider<PrivateChatRemoteDataSource>((ref) {
  return PrivateChatRemoteDataSourceImpl(
    ref.watch(dioClientProvider),
  );
});

/// Provider for PrivateChatLocalDataSource.
final privateChatLocalDataSourceProvider =
    Provider<PrivateChatLocalDataSource>((ref) {
  return PrivateChatLocalDataSourceImpl(
    ref.watch(chatCoreLocalDataSourceProvider),
  );
});

/// Provider for PrivateChatRepository.
final privateChatRepositoryProvider = Provider<PrivateChatRepository>((ref) {
  return PrivateChatRepositoryImpl(
    remoteDataSource: ref.watch(privateChatRemoteDataSourceProvider),
    localDataSource: ref.watch(privateChatLocalDataSourceProvider),
  );
});

/// Provider for CreatePrivateChatUseCase.
final createPrivateChatUseCaseProvider =
    Provider<CreatePrivateChatUseCase>((ref) {
  return CreatePrivateChatUseCase(ref.watch(privateChatRepositoryProvider));
});

/// Provider for SendMessageUseCase.
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

/// Provider for DeleteMessageUseCase.
final deleteLocalMessageUseCaseProvider =
    Provider<DeleteLocalMessageUseCase>((ref) {
  return DeleteLocalMessageUseCase(
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
  );
});

/// Provider for UpdateMessageUseCase.
final updateMessageUseCaseProvider = Provider<UpdateMessageUseCase>((ref) {
  return UpdateMessageUseCase(
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

/// Provider for GetConversationUseCase.
final getRemoteConversationUseCaseProvider =
    Provider<GetRemoteConversationUseCase>((ref) {
  return GetRemoteConversationUseCase(
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

/// Provider for GetRemoteMessageUseCase
final getRemoteMessageUseCaseProvider =
    Provider<GetRemoteMessageUseCase>((ref) {
  return GetRemoteMessageUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});

/// Provider for DeleteRemoteMessageUseCase
final deleteRemoteMessageUseCaseProvider =
    Provider<DeleteRemoteMessageUseCase>((ref) {
  return DeleteRemoteMessageUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});
