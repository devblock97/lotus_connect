import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/auth/domain/entities/user.dart';
import 'package:lotus_connect/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<User?> call(NoParams params) {
    return _repository.getCachedUser();
  }
}
