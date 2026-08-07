import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/features/chat/domain/repositories/private_chat_repository.dart';
import 'package:lotus_connect/features/chat/domain/usecases/update_message_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';
import 'package:lotus_connect/features/chat_core/domain/repositories/chat_core_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPrivateChatRepository extends Mock implements PrivateChatRepository {}
class MockChatCoreRepository extends Mock implements ChatCoreRepository {}

void main() {
  late MockPrivateChatRepository mockPrivateChatRepo;
  late MockChatCoreRepository mockChatCoreRepo;
  late UpdateMessageUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Message(
      id: '',
      conversationId: '',
      role: MessageRole.user,
      content: '',
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockPrivateChatRepo = MockPrivateChatRepository();
    mockChatCoreRepo = MockChatCoreRepository();
    useCase = UpdateMessageUseCase(
      chatCoreRepository: mockChatCoreRepo,
      privateChatRepository: mockPrivateChatRepo,
    );
  });

  final testUuid = '00000000-0000-0000-0000-000000000001';
  final testLegacyId = '1234567890';
  final testContent = 'Updated Content';

  final baseMessage = Message(
    id: testUuid,
    conversationId: 'test_conv',
    role: MessageRole.user,
    content: 'Old Content',
    timestamp: DateTime.now(),
  );

  test('should update message remotely and locally when ID is a valid UUID', () async {
    when(() => mockPrivateChatRepo.updateMessage(
          messageId: testUuid,
          content: testContent,
        )).thenAnswer((_) async => const Right(null));

    when(() => mockChatCoreRepo.getMessage(testUuid))
        .thenAnswer((_) async => Right(baseMessage));

    when(() => mockChatCoreRepo.saveMessage(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(
      UpdateMessageParam(messageId: testUuid, content: testContent),
    );

    expect(result, const Right<Failure, void>(null));

    verify(() => mockPrivateChatRepo.updateMessage(
          messageId: testUuid,
          content: testContent,
        )).called(1);

    verify(() => mockChatCoreRepo.getMessage(testUuid)).called(1);
    verify(() => mockChatCoreRepo.saveMessage(any(
      that: isA<Message>().having((m) => m.content, 'content', testContent),
    ))).called(1);
  });

  test('should only update message locally when ID is a legacy non-UUID', () async {
    final legacyMessage = baseMessage.copyWith(id: testLegacyId);

    when(() => mockChatCoreRepo.getMessage(testLegacyId))
        .thenAnswer((_) async => Right(legacyMessage));

    when(() => mockChatCoreRepo.saveMessage(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(
      UpdateMessageParam(messageId: testLegacyId, content: testContent),
    );

    expect(result, const Right<Failure, void>(null));

    verifyNever(() => mockPrivateChatRepo.updateMessage(
          messageId: any(named: 'messageId'),
          content: any(named: 'content'),
        ));

    verify(() => mockChatCoreRepo.getMessage(testLegacyId)).called(1);
    verify(() => mockChatCoreRepo.saveMessage(any(
      that: isA<Message>().having((m) => m.content, 'content', testContent),
    ))).called(1);
  });

  test('should return failure when remote update fails', () async {
    final serverFailure = ServerFailure('API Error');

    when(() => mockPrivateChatRepo.updateMessage(
          messageId: testUuid,
          content: testContent,
        )).thenAnswer((_) async => Left(serverFailure));

    final result = await useCase(
      UpdateMessageParam(messageId: testUuid, content: testContent),
    );

    expect(result, Left<Failure, void>(serverFailure));

    verifyNever(() => mockChatCoreRepo.getMessage(any()));
    verifyNever(() => mockChatCoreRepo.saveMessage(any()));
  });
}
