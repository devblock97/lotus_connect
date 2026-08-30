import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class AcceptFriendRequestParam extends Equatable {
  const AcceptFriendRequestParam({required this.targetId});

  final String targetId;

  @override
  List<Object?> get props => [targetId];
}

class AcceptFriendRequestUseCase
    implements UseCase<void, AcceptFriendRequestParam> {
  const AcceptFriendRequestUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<void> call(AcceptFriendRequestParam params) async {
    return _repository.acceptFriendRequest(targetId: params.targetId);
  }
}
