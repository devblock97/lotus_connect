import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';

/// Use case to watch message lists for a conversation.
class GetMessagesUseCase implements StreamUseCase<List<Message>, String> {
  /// Constructor taking [ChatCoreRepository].
  const GetMessagesUseCase(this._repository);

  final ChatCoreRepository _repository;

  @override
  StreamResult<List<Message>> call(String params) {
    return _repository.watchMessages(params);
  }
}
