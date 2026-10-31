import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/entities/user_profile.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class GetProfileParams {
  const GetProfileParams({
    this.userId,
    this.username,
  });

  final String? userId;
  final String? username;
}

class GetProfileUseCase implements UseCase<UserProfile, GetProfileParams> {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<UserProfile> call(GetProfileParams params) {
    final username = params.username?.trim();
    if (username != null && username.isNotEmpty) {
      final cleanUsername =
          username.startsWith('@') ? username.substring(1) : username;
      return _repository.getUserProfileByUsername(cleanUsername);
    }

    final userId = params.userId?.trim();
    if (userId != null && userId.isNotEmpty && userId != 'me') {
      return _repository.getUserProfile(userId);
    }

    return _repository.getMyProfile();
  }
}
