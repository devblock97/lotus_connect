import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/contacts/domain/repositories/contacts_repository.dart';

class RejectFriendRequestParam extends Equatable {
  const RejectFriendRequestParam({required this.targetId});

  final String targetId;

  @override
  List<Object?> get props => [targetId];
}

class RejectFriendRequestUseCase
    implements UseCase<ResponseEntityBase, RejectFriendRequestParam> {
  const RejectFriendRequestUseCase({required ContactsRepository repository})
      : _repository = repository;

  final ContactsRepository _repository;

  @override
  FutureResult<ResponseEntityBase> call(RejectFriendRequestParam params) async {
    return _repository.rejectFriendRequest(targetId: params.targetId);
  }
}
