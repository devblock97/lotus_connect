import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/entities/response_entity_base.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPrivateChatRepository extends Mock implements PrivateChatRepository {}

class MockChatCoreRepository extends Mock implements ChatCoreRepository {}

void main() {
  late MockPrivateChatRepository mockPrivateChatRepo;
  late MockChatCoreRepository mockChatCoreRepo;
  late UpdateMessageUseCase useCase;

  setUp(() {
    mockPrivateChatRepo = MockPrivateChatRepository();
    mockChatCoreRepo = MockChatCoreRepository();
    useCase = UpdateMessageUseCase(
      chatCoreRepository: mockChatCoreRepo,
      privateChatRepository: mockPrivateChatRepo,
    );
  });

  const testMessageId = '00000000-0000-0000-0000-000000000001';
  const testContent = 'Updated Content';
  const testParams = UpdateMessageParam(
    messageId: testMessageId,
    content: testContent,
  );

  const testMessageResponse = ResponseEntityBase(
    isSuccess: true,
    message: 'Message updated',
  );

  group('UpdateMessageUseCase', () {
    test('should return ResponseEntityBase when repository update succeeds',
        () async {
      // Arrange
      when(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).thenAnswer((_) async => const Right(testMessageResponse));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(
        result,
        const Right<Failure, ResponseEntityBase>(testMessageResponse),
      );
      verify(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPrivateChatRepo);
      verifyZeroInteractions(mockChatCoreRepo);
    });

    test('should return ServerFailure when repository update fails', () async {
      // Arrange
      const serverFailure = ServerFailure('Failed to update message on server');
      when(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).thenAnswer((_) async => const Left(serverFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Left<Failure, ResponseEntityBase>(serverFailure));
      verify(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPrivateChatRepo);
      verifyZeroInteractions(mockChatCoreRepo);
    });

    test('should return NetworkFailure when device has no internet connection',
        () async {
      // Arrange
      const networkFailure = NetworkFailure('No internet connection');
      when(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).thenAnswer((_) async => const Left(networkFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Left<Failure, ResponseEntityBase>(networkFailure));
      verify(
        () => mockPrivateChatRepo.updateMessage(
          messageId: testMessageId,
          content: testContent,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockPrivateChatRepo);
      verifyZeroInteractions(mockChatCoreRepo);
    });
  });
}
