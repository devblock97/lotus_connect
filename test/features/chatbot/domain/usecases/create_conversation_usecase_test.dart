import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:lotus_connect/features/chatbot/domain/usecases/create_conversation_usecase.dart';

class MockChatbotRepository extends Mock implements ChatbotRepository {}

void main() {
  late MockChatbotRepository mockRepository;
  late CreateConversationUseCase useCase;

  setUp(() {
    mockRepository = MockChatbotRepository();
    useCase = CreateConversationUseCase(mockRepository);
  });

  test('should create conversation successfully from repository', () async {
    final expectedConversation = Conversation(
      id: '123',
      title: 'Test Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    when(
      () => mockRepository.createConversation(
        title: 'Test Chat',
        modelName: 'gpt-4o',
      ),
    ).thenAnswer((_) async => Right(expectedConversation));

    final result = await useCase(
      const CreateConversationParams(
        title: 'Test Chat',
        modelName: 'gpt-4o',
      ),
    );

    expect(result, Right(expectedConversation));
    verify(
      () => mockRepository.createConversation(
        title: 'Test Chat',
        modelName: 'gpt-4o',
      ),
    ).called(1);
  });
}
