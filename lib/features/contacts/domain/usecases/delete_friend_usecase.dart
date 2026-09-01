import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class DeleteFriendParam extends Equatable {
  const DeleteFriendParam({required this.friendId});

  final String friendId;

  @override
  List<Object?> get props => [friendId];
}

class DeleteFriendUseCase
    implements UseCase<ResponseEntityBase, DeleteFriendParam> {
  const DeleteFriendUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(DeleteFriendParam params) async {
    return _repository.deleteFriend(friendId: params.friendId);
  }
}
