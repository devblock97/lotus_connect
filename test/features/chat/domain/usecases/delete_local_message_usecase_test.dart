import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_local_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatCoreRepository extends Mock implements ChatCoreRepository {}

void main() {
  late MockChatCoreRepository mockChatCorRepo;
  late DeleteLocalMessageUseCase useCase;

  setUp(() {
    mockChatCorRepo = MockChatCoreRepository();
    useCase = DeleteLocalMessageUseCase(chatCoreRepository: mockChatCorRepo);
  });

  const testMessageId = '00000000-0000-0000-0000-000000000001';

  group('DeleteLocalMessageRepository', () {
    test('should return LocalFailure when delete message fails', () async {
      const databaseFailure =
          DatabaseFailure('Failed to delete message from local database');
      when(() => mockChatCorRepo.deleteMessage(testMessageId))
          .thenAnswer((_) async => const Left(databaseFailure));

      final result = await useCase(testMessageId);

      expect(result, const Left<Failure, void>(databaseFailure));
      verify(() => mockChatCorRepo.deleteMessage(testMessageId)).called(1);
      verifyNoMoreInteractions(mockChatCorRepo);
    });

    test(
        'should forward call to ChatCoreRepository and return Right(null) on success',
        () async {
      when(() => mockChatCorRepo.deleteMessage(testMessageId))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(testMessageId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockChatCorRepo.deleteMessage(testMessageId)).called(1);
      verifyNoMoreInteractions(mockChatCorRepo);
    });

    test('should return UnknownFailure when an expected error occurs',
        () async {
      const unknownFailure = UnknownFailure('Unexpected sqlite error');
      when(() => mockChatCorRepo.deleteMessage(testMessageId))
          .thenAnswer((_) async => const Left(unknownFailure));

      final result = await useCase(testMessageId);

      expect(result, const Left<Failure, void>(unknownFailure));
      verify(() => mockChatCorRepo.deleteMessage(testMessageId));
      verifyNoMoreInteractions(mockChatCorRepo);
    });
  });
}
