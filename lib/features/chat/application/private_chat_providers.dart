import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotus_connect/core/services/api/chat_api_service.dart';
import 'package:lotus_connect/features/chat/data/repositories/private_chat_repository_impl.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';

/// Provider for PrivateChatRepository.
final privateChatRepositoryProvider = Provider<PrivateChatRepository>((ref) {
  return PrivateChatRepositoryImpl(
    chatApiService: ref.watch(chatApiServiceProvider),
    chatCoreRepository: ref.watch(chatCoreRepositoryProvider),
  );
});
