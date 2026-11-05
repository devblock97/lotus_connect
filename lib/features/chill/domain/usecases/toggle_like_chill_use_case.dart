import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/chill/domain/repositories/chill_repository.dart';

class ToggleLikeChillParams extends Equatable {
  const ToggleLikeChillParams({
    required this.chillId,
    required this.isLiked,
    this.reaction,
  });

  final String chillId;
  final bool isLiked;
  final String? reaction;

  @override
  List<Object?> get props => [chillId, isLiked, reaction];
}

class ToggleLikeChillUseCase implements UseCase<bool, ToggleLikeChillParams> {
  const ToggleLikeChillUseCase({required ChillRepository repository})
      : _repository = repository;

  final ChillRepository _repository;

  @override
  FutureResult<bool> call(ToggleLikeChillParams params) {
    return _repository.toggleLikeChill(
      params.chillId,
      isLiked: params.isLiked,
      reaction: params.reaction,
    );
  }
}
