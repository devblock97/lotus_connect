import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/network/dio_client.dart';
import 'package:lotus_connect/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:lotus_connect/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:lotus_connect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lotus_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_conversation_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/reaction_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/upload_file_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_message_usecase.dart';

final privateChatRemoteDataSourceProvider =
    Provider<PrivateChatRemoteDataSource>((ref) {
  return PrivateChatRemoteDataSourceImpl(
    ref.watch(dioClientProvider),
  );
});

final privateChatLocalDataSourceProvider =
    Provider<PrivateChatLocalDataSource>((ref) {
  return PrivateChatLocalDataSourceImpl(
    ref.watch(chatCoreLocalDataSourceProvider),
  );
});

final privateChatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDataSource: ref.watch(privateChatRemoteDataSourceProvider),
    localDataSource: ref.watch(privateChatLocalDataSourceProvider),
  );
});

final createConversationUseCaseProvider =
    Provider<CreateConversationUseCase>((ref) {
  return CreateConversationUseCase(ref.watch(privateChatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

final deleteLocalMessageUseCaseProvider =
    Provider<DeleteLocalMessageUseCase>((ref) {
  return DeleteLocalMessageUseCase(
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
  );
});

final updateMessageUseCaseProvider = Provider<UpdateMessageUseCase>((ref) {
  return UpdateMessageUseCase(
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

final getRemoteConversationUseCaseProvider =
    Provider<GetRemoteConversationUseCase>((ref) {
  return GetRemoteConversationUseCase(
    privateChatRepository: ref.watch(privateChatRepositoryProvider),
  );
});

final getRemoteMessageUseCaseProvider =
    Provider<GetRemoteMessageUseCase>((ref) {
  return GetRemoteMessageUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});

final deleteRemoteMessageUseCaseProvider =
    Provider<DeleteRemoteMessageUseCase>((ref) {
  return DeleteRemoteMessageUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});

final reactionMessageUseCaseProvider = Provider<ReactionMessageUseCase>((ref) {
  return ReactionMessageUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});

final uploadFileUseCaseProvider = Provider<UploadFileUseCase>((ref) {
  return UploadFileUseCase(
    repository: ref.watch(privateChatRepositoryProvider),
  );
});

final getMessageUseCaseProvider = Provider<GetMessageUseCase>((ref) {
  return GetMessageUseCase(repository: ref.watch(chatCoreRepositoryProvider));
});
