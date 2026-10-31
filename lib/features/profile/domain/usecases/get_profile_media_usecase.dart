import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/profile/domain/entities/profile_media_item.dart';
import 'package:lotus_connect/features/profile/domain/repositories/profile_repository.dart';

class GetProfileMediaParams {
  const GetProfileMediaParams({
    this.userId,
    this.mediaType,
    this.cursor,
    this.limit = 24,
  });

  final String? userId;
  final String? mediaType;
  final String? cursor;
  final int? limit;
}

class GetProfileMediaUseCase
    implements UseCase<List<ProfileMediaItem>, GetProfileMediaParams> {
  const GetProfileMediaUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<List<ProfileMediaItem>> call(GetProfileMediaParams params) {
    return _repository.getUserMedia(
      userId: params.userId,
      mediaType: params.mediaType,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}
