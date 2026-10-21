import 'package:equatable/equatable.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/core/utils/typedefs.dart';
import 'package:lotus_connect/features/livestream/domain/entities/live_gift.dart';
import 'package:lotus_connect/features/livestream/domain/repositories/livestream_repository.dart';

class SendGiftParam extends Equatable {
  const SendGiftParam({
    required this.streamId,
    this.reaction = 'heart',
    this.count = 1,
  });

  final String streamId;
  final String reaction;
  final int count;
  @override
  List<Object?> get props => [
        streamId,
        reaction,
        count,
      ];
}

class SendGiftUseCase implements UseCase<LiveGiftEvent, SendGiftParam> {
  const SendGiftUseCase(LiveStreamRepository repository)
      : _repository = repository;

  final LiveStreamRepository _repository;

  @override
  FutureResult<LiveGiftEvent> call(SendGiftParam params) async {
    return _repository.sendGift(
      params.streamId,
      giftType: params.reaction,
      count: params.count,
    );
  }
}
