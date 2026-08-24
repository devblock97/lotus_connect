import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class DeleteLocalMessageUseCase implements UseCase<void, String> {
  const DeleteLocalMessageUseCase({
    required ChatCoreRepository chatCoreRepository,
  }) : _chatCoreRepository = chatCoreRepository;

  final ChatCoreRepository _chatCoreRepository;

  @override
  FutureResult<void> call(String messageId) async {
    return _chatCoreRepository.deleteMessage(messageId);
  }
}
