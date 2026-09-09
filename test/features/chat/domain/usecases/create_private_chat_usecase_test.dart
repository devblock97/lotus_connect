import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/create_private_chat_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:mocktail/mocktail.dart';

class MockChatPrivateRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatPrivateRepository mockChatRepo;
  late CreatePrivateChatUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatPrivateRepository();
    useCase = CreatePrivateChatUseCase(mockChatRepo);
  });

  const convId = '01a0860a-0ff3-75e3-9dd9-5089c46eeb80';
  const testFriendId = '01a05372-b2b6-74d1-838d-d406cadbea12';
  const testTitle = 'Test title';
  final testConversation = Conversation(
    id: convId,
    peerId: testFriendId,
    title: testTitle,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('createPrivateChatUseCase', () {
    test('should return Right(Conversation) when create chat succeeds',
        () async {
      when(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).thenAnswer((_) async => Right(testConversation));

      final result = await useCase(
        const CreatePrivateChatParams(
          friendId: testFriendId,
          title: testTitle,
        ),
      );

      expect(result, Right<Failure, Conversation>(testConversation));
      verify(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return Left(ServerFailure) when create chat fails', () async {
      const serverFailure = ServerFailure('Failed to create chat');
      when(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(
        const CreatePrivateChatParams(
          friendId: testFriendId,
          title: testTitle,
        ),
      );

      expect(result, const Left<Failure, Conversation>(serverFailure));
      verify(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return NetworkFailure when device has no internet connection',
        () async {
      const networkFailure = ServerFailure('No internet connection');
      when(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(
        const CreatePrivateChatParams(
          friendId: testFriendId,
          title: testTitle,
        ),
      );

      expect(result, const Left<Failure, Conversation>(networkFailure));
      verify(
        () => mockChatRepo.createPrivateChat(
          friendId: testFriendId,
          title: testTitle,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });
  });
}
