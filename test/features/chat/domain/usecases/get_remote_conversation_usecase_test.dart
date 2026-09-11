import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements PrivateChatRepository {}

void main() {
  late MockChatRepository mockChatRepo;
  late GetRemoteConversationUseCase useCase;

  setUp(() {
    mockChatRepo = MockChatRepository();
    useCase = GetRemoteConversationUseCase(privateChatRepository: mockChatRepo);
  });

  const testConvId = '01a08654-ba94-7f10-8acf-7dffa97b16ff';
  const testTitle = 'Test title';
  const testPeerId = '01a04ce5-0028-78d3-9736-20a36804402e';

  final testConversation = Conversation(
    id: testConvId,
    title: testTitle,
    peerId: testPeerId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isUserToUser: true,
  );

  final testConversations = [testConversation];

  group('GetRemoteConversationUseCase', () {
    test(
        'should return Right(List<Conversation>) when '
        'call getConversationList succeeds', () async {
      when(() => mockChatRepo.getConversationList())
          .thenAnswer((_) async => Right(testConversations));

      final result = await useCase(const NoParams());

      expect(result, Right<Failure, List<Conversation>>(testConversations));
      verify(() => mockChatRepo.getConversationList()).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return ServerFailure when repository call fails', () async {
      const serverFailure = ServerFailure('Server Error');
      when(() => mockChatRepo.getConversationList())
          .thenAnswer((_) async => const Left(serverFailure));

      final result = await useCase(const NoParams());

      expect(result, const Left<Failure, List<Conversation>>(serverFailure));
      verify(() => mockChatRepo.getConversationList()).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });

    test('should return NetworkFailure when device has no internet connection',
        () async {
      const networkFailure = NetworkFailure('No internet connection');
      when(() => mockChatRepo.getConversationList())
          .thenAnswer((_) async => const Left(networkFailure));

      final result = await useCase(const NoParams());

      expect(result, const Left<Failure, List<Conversation>>(networkFailure));
      verify(() => mockChatRepo.getConversationList()).called(1);
      verifyNoMoreInteractions(mockChatRepo);
    });
  });
}
