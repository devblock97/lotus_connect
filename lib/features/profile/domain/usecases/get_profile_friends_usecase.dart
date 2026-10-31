import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class GetProfileFriendsUseCase implements UseCase<List<User>, String?> {
  const GetProfileFriendsUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<List<User>> call(String? userId) {
    return _repository.getUserFriends(userId: userId);
  }
}
