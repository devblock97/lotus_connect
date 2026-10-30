import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

class GetPendingMessagesUseCase implements UseCase<List<Message>, NoParams> {
  GetPendingMessagesUseCase({required ChatCoreRepository repository})
      : _repository = repository;

  final ChatCoreRepository _repository;

  @override
  FutureResult<List<Message>> call(NoParams params) async {
    return _repository.getPendingMessages();
  }
}
