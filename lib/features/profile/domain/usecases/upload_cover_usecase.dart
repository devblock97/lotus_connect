import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class UploadCoverUseCase implements UseCase<UserProfile, String> {
  const UploadCoverUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<UserProfile> call(String filePath) {
    return _repository.uploadCover(filePath);
  }
}
