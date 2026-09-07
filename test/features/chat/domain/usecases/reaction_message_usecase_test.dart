import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/entities/reaction_message_entity.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/reaction_message_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatRepository mockChatRepo;
  late ReactionMessageUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepository();
    useCase = ReactionMessageUseCase(repository: mockChatRepo);
  });

  const testMessageId = '01a075be-de0a-7900-91d8-b3448423195e';
  const testUserId = '01a03314-af86-72f3-b270-d5642b05fbdc';
  final defaultEmojis = ['👍', '❤️', '😂', '😮', '😢', '🔥', '🙏'];
  final reaction = defaultEmojis.first;

  final reactionParams = ReactionMessageParam(
    messageId: testMessageId,
    reaction: reaction,
  );

  group('ReactionMessageUseCase', () {
    test('should return NetworkFailure when react message fails', () async {
      const serverFailure = ServerFailure('Failed to reaction from server');
      when(() => mockChatRepo.reactMessage(testMessageId, reaction))
          .thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(reactionParams);

      expect(result, const Left<Failure, ReactionMessageEntity>(serverFailure));
      verify(() => mockChatRepo.reactMessage(testMessageId, reaction))
          .called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return ReactionMessageEntity when react message success',
        () async {
      final reactionResponse = ReactionMessageEntity(
        messageId: testMessageId,
        userId: testUserId,
        reaction: reaction,
        createdAt: DateTime.now(),
      );

      when(() => mockChatRepo.reactMessage(testMessageId, reaction))
          .thenAnswer((_) async => Right(reactionResponse));

      final result = await useCase(reactionParams);

      expect(result, Right<Failure, ReactionMessageEntity>(reactionResponse));
      verify(() => mockChatRepo.reactMessage(testMessageId, reaction))
          .called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return NetworkFailure when device has no internet connection',
        () async {
      const networkFailure = NetworkFailure('No internet connection');
      when(() => mockChatRepo.reactMessage(testMessageId, reaction))
          .thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(reactionParams);

      expect(
        result,
        const Left<Failure, ReactionMessageEntity>(networkFailure),
      );
      verify(
        () => mockChatRepo.reactMessage(testMessageId, reaction),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });
  });
}
