import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase implements UseCase<String, String> {
  const UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<String> call(String filePath) {
    return _repository.uploadAvatar(filePath);
  }
}
