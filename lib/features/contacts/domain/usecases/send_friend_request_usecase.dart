import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class SendFriendRequestParam extends Equatable {
  const SendFriendRequestParam({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

class SendFriendRequestUseCase
    implements UseCase<void, SendFriendRequestParam> {
  const SendFriendRequestUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<void> call(SendFriendRequestParam params) async {
    return _repository.sendFriendRequest(username: params.username);
  }
}
