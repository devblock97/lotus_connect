import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_stream.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

/// Parameters for creating a live stream.
class CreateStreamParam extends Equatable {
  const CreateStreamParam({
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.privacy,
  });

  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? privacy;

  @override
  List<Object?> get props => [
        title,
        description,
        thumbnailUrl,
        privacy,
      ];
}

typedef CreateStreamParams = CreateStreamParam;

/// Use case responsible for creating a new live stream broadcast.
class CreateStreamUseCase implements UseCase<LiveStream, CreateStreamParam> {
  const CreateStreamUseCase(this._repository);

  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveStream> call(CreateStreamParam params) async {
    final trimmedTitle = params.title.trim();
    if (trimmedTitle.isEmpty) {
      return const Left(ValidationFailure('Stream title cannot be empty'));
    }

    final trimmedDescription = params.description?.trim();

    return _repository.createStream(
      title: trimmedTitle,
      description: trimmedDescription != null && trimmedDescription.isNotEmpty
          ? trimmedDescription
          : null,
      thumbnailUrl: params.thumbnailUrl,
      privacy: params.privacy,
    );
  }
}
