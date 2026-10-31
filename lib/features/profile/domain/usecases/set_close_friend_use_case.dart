import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class SetCloseFriendParam extends Equatable {
  const SetCloseFriendParam({
    required this.friendId,
    required this.isCloseFriend,
  });

  final String friendId;
  final bool isCloseFriend;

  @override
  List<Object?> get props => [
        friendId,
        isCloseFriend,
      ];
}

class SetCloseFriendUseCase implements UseCase<bool, SetCloseFriendParam> {
  SetCloseFriendUseCase({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  @override
  FutureResult<bool> call(SetCloseFriendParam params) async {
    return _repository.setCloseFriend(
      friendId: params.friendId,
      isCloseFriend: params.isCloseFriend,
    );
  }
}
