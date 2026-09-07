import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/delete_remote_message_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockPrivateChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockPrivateChatRepository mockPrivateChatRepo;
  late DeleteRemoteMessageUseCase useCase;

  setUp(() {
    mockPrivateChatRepo = MockPrivateChatRepository();
    useCase = DeleteRemoteMessageUseCase(repository: mockPrivateChatRepo);
  });

  const testMessageId = '00000000-0000-0000-0000-000000000001';
  const testParams = DeleteRemoteMessageParam(messageId: testMessageId);

  group('DeleteRemoteMessageUseCase', () {
    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const serverFailure = ServerFailure('Failed to delete message on server');
      when(
        () => mockPrivateChatRepo.deleteMessage(testMessageId),
      ).thenAnswer((_) async => const Left(serverFailure));

      // Act
      final result = await useCase(
        const DeleteRemoteMessageParam(messageId: testMessageId),
      );

      // Assert
      expect(result, const Left<Failure, void>(serverFailure));
      verify(() => mockPrivateChatRepo.deleteMessage(testMessageId)).called(1);
      verifyNoMoreInteractions(mockPrivateChatRepo);
    });

    test('should forward call to repository and return Right(null) on success',
        () async {
      when(() => mockPrivateChatRepo.deleteMessage(testMessageId))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(testParams);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockPrivateChatRepo.deleteMessage(testMessageId)).called(1);
      verifyNoMoreInteractions(mockPrivateChatRepo);
    });
  });

  test('should return NetworkFailure when there is no internet connection',
      () async {
    const networkFailure = NetworkFailure('No internet connection');
    when(() => mockPrivateChatRepo.deleteMessage(testMessageId))
        .thenAnswer((_) async => const Left(networkFailure));

    final result = await useCase(testParams);

    expect(result, const Left<Failure, void>(networkFailure));
    verify(() => mockPrivateChatRepo.deleteMessage(testMessageId)).called(1);
    verifyNoMoreInteractions(mockPrivateChatRepo);
  });

  group('DeleteRemoteMessageParam', () {
    test('should support value equality', () {
      const param1 = DeleteRemoteMessageParam(messageId: testMessageId);
      const param2 = DeleteRemoteMessageParam(messageId: testMessageId);
      const param3 = DeleteRemoteMessageParam(messageId: 'different-id');

      expect(param1, equals(param2));
      expect(param2, isNot(param3));
    });

    test('props should contain messageId', () {
      expect(testParams.props, [testMessageId]);
    });
  });
}
