import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/entities/update_profile_params.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase
    implements UseCase<UserProfile, UpdateProfileParams> {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<UserProfile> call(UpdateProfileParams params) {
    return _repository.updateMyProfile(params);
  }
}
