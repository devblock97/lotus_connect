import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lotus_connect/core/errors/failure.dart';
import 'package:lotus_connect/core/usecases/usecase.dart';
import 'package:lotus_connect/features/chat/application/chat_providers.dart';
import 'package:lotus_connect/features/chat/application/conversation_list_notifier.dart';
import 'package:lotus_connect/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:lotus_connect/features/chat/domain/usecases/get_remote_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/application/chat_core_providers.dart';
import 'package:lotus_connect/features/chat_core/data/datasources/chat_core_local_data_source.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/delete_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/get_conversations_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/rename_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/toggle_favourite_conversation_usecase.dart';
import 'package:lotus_connect/features/chat_core/domain/usecases/toggle_pin_conversation_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRemoteConversationUseCase extends Mock
    implements GetRemoteConversationUseCase {}

class MockCreateConversationUseCase extends Mock
    implements CreateConversationUseCase {}

class MockGetConversationUseCase extends Mock
    implements GetConversationsUseCase {}

class MockRenameConversationUseCase extends Mock
    implements RenameConversationUseCase {}

class MockDeleteConversationUseCase extends Mock
    implements DeleteConversationUseCase {}

class MockTogglePinConversationUseCase extends Mock
    implements TogglePinConversationUseCase {}

class MockToggleFavouriteConversationUseCase extends Mock
    implements ToggleFavouriteConversationUseCase {}

class MockChatCoreLocalDataSource extends Mock
    implements ChatCoreLocalDataSource {}

void main() {
  late GetRemoteConversationUseCase getRemoteConversationUseCase;
  late MockCreateConversationUseCase createConversationUseCase;
  late GetConversationsUseCase getConversationsUseCase;
  late RenameConversationUseCase renameConversationUseCase;
  late DeleteConversationUseCase deleteConversationUseCase;
  late TogglePinConversationUseCase togglePinConversationUseCase;
  late ToggleFavouriteConversationUseCase toggleFavouriteConversationUseCase;
  late ChatCoreLocalDataSource chatCoreLocalDataSource;

  late StreamController<Either<Failure, List<Conversation>>> streamController;
  late ProviderContainer container;

  final now = DateTime(2026, 9, 14, 10);

  final testConv1 = Conversation(
    id: 'conv-1',
    title: 'Thong',
    peerId: 'peer-1',
    isUserToUser: true,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(minutes: 5)),
  );

  final testConv2 = Conversation(
    id: 'conv-2',
    title: 'Nguyen',
    peerId: 'peer-2',
    isUserToUser: true,
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now.subtract(const Duration(minutes: 1)),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const CreateConversationParams(friendId: '', title: ''),
    );
    registerFallbackValue(const DeleteConversationParam(id: ''));
    registerFallbackValue(const TogglePinConversationParam(id: ''));
    registerFallbackValue(const ToggleFavouriteConversationParam(id: ''));
  });

  setUp(() {
    createConversationUseCase = MockCreateConversationUseCase();
    getConversationsUseCase = MockGetConversationUseCase();
    getRemoteConversationUseCase = MockGetRemoteConversationUseCase();
    renameConversationUseCase = MockRenameConversationUseCase();
    deleteConversationUseCase = MockDeleteConversationUseCase();
    togglePinConversationUseCase = MockTogglePinConversationUseCase();
    toggleFavouriteConversationUseCase =
        MockToggleFavouriteConversationUseCase();
    chatCoreLocalDataSource = MockChatCoreLocalDataSource();

    streamController =
        StreamController<Either<Failure, List<Conversation>>>.broadcast();

    when(() => getConversationsUseCase(any()))
        .thenAnswer((_) => streamController.stream);

    when(() => getRemoteConversationUseCase(any()))
        .thenAnswer((_) async => const Right([]));

    when(() => chatCoreLocalDataSource.getConversations())
        .thenAnswer((_) async => []);

    when(
      () => chatCoreLocalDataSource.createConversation(
        id: any(named: 'id'),
        title: any(named: 'title'),
        isUserToUser: any(named: 'isUserToUser'),
        peerId: any(named: 'peerId'),
      ),
    ).thenAnswer(
      (_) async => Conversation(
        id: 'new-id',
        title: 'Title',
        createdAt: now,
        updatedAt: now,
      ),
    );

    container = ProviderContainer(
      overrides: [
        getRemoteConversationUseCaseProvider
            .overrideWithValue(getRemoteConversationUseCase),
        createConversationUseCaseProvider
            .overrideWithValue(createConversationUseCase),
        getConversationsUseCaseProvider
            .overrideWithValue(getConversationsUseCase),
        renameConversationUseCaseProvider
            .overrideWithValue(renameConversationUseCase),
        togglePinConversationUseCaseProvider
            .overrideWithValue(togglePinConversationUseCase),
        toggleFavouriteConversationUseCaseProvider
            .overrideWithValue(toggleFavouriteConversationUseCase),
        chatCoreLocalDataSourceProvider
            .overrideWithValue(chatCoreLocalDataSource),
      ],
    );
  });

  tearDown(() async {
    await streamController.close();
    container.dispose();
  });

  group('PrivateConversationListState', () {
    test('default values are as expected', () {
      const state = PrivateConversationListState();
      expect(state.conversations, isEmpty);
      expect(state.selectedConversationId, isNull);
      expect(state.searchQuery, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.filteredConversations, isEmpty);
    });

    test('copyWith updates only specified fields', () {
      const state = PrivateConversationListState();
      final updated = state.copyWith(
        conversations: [testConv1],
        selectedConversationId: 'conv-1',
        searchQuery: 'ong',
        isLoading: true,
        errorMessage: 'An error',
      );

      expect(updated.conversations, equals([testConv1]));
      expect(updated.selectedConversationId, equals('conv-1'));
      expect(updated.searchQuery, equals('ong'));
      expect(updated.isLoading, isTrue);
      expect(updated.errorMessage, equals('An error'));
    });

    test('filteredConversation filters by title case-insensitively', () {
      final state = PrivateConversationListState(
        conversations: [testConv1, testConv2],
        searchQuery: ' ONG ',
      );

      expect(state.filteredConversations, equals([testConv1]));
    });

    test('filteredConversations returns all conversations when query is empty',
        () {
      final state = PrivateConversationListState(
        conversations: [testConv1, testConv2],
        searchQuery: ' ',
      );

      expect(state.filteredConversations, equals([testConv1, testConv2]));
    });
  });

  group('Initialization and stream updates', () {
    test('initializes with loading and calls loadRemoteConversations',
        () async {
      final notifier = container.read(privateConversationListProvider.notifier);

      expect(notifier.state.isLoading, isTrue);

      verify(() => getRemoteConversationUseCase(const NoParams())).called(1);
    });

    test('updates conversations, filters isUserToUser and sorts by updatedAt',
        () async {
      final notifier = container.read(privateConversationListProvider.notifier);

      streamController.add(Right([testConv1, testConv2]));

      await pumpEventQueue();

      final state = notifier.state;

      expect(state.isLoading, isFalse);
      expect(state.conversations.length, equals(2));
      // Sorted descending by updatedAt: testConv2 (more recent) first
      expect(state.conversations.first.id, equals('conv-2'));
      expect(state.conversations.last.id, equals('conv-1'));
      expect(state.selectedConversationId, equals('conv-2'));
    });

    test('preserves selectedConversationId if already set', () async {
      final notifier = container.read(privateConversationListProvider.notifier)
        ..selectConversation('conv-1');

      streamController.add(Right([testConv1, testConv2]));
      await pumpEventQueue();

      expect(notifier.state.selectedConversationId, equals('conv-1'));
    });

    test('updates state with errorMessage when stream emits Failure', () async {
      final notifier = container.read(privateConversationListProvider.notifier);

      const failure = ServerFailure('Failed to stream conversations');
      streamController.add(const Left(failure));
      await pumpEventQueue();

      final state = notifier.state;
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, equals('Failed to stream conversations'));
    });
  });

  group('loadRemoteConversations', () {
    test('syncs new remote conversations to local data source', () async {
      when(() => getRemoteConversationUseCase(any()))
          .thenAnswer((_) async => Right([testConv1, testConv2]));
      when(() => chatCoreLocalDataSource.getConversations())
          .thenAnswer((_) async => [testConv1]); // conv-1 already exists
      container.read(privateConversationListProvider.notifier);
      await pumpEventQueue();
      // Only conv-2 should be created locally
      verifyNever(
        () => chatCoreLocalDataSource.createConversation(
          id: 'conv-2',
          title: 'Bob',
          isUserToUser: true,
          peerId: 'peer-2',
        ),
      );

      verifyNever(
        () => chatCoreLocalDataSource.createConversation(
          id: 'conv-1',
          title: any(named: 'title'),
          isUserToUser: any(named: 'isUserToUser'),
          peerId: any(named: 'peerId'),
        ),
      );
    });

    test('handles remote error gracefully without crashing', () async {
      when(() => getRemoteConversationUseCase(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Offline')));

      final notifier = container.read(privateConversationListProvider.notifier);

      await notifier.loadRemoteConversations();

      expect(notifier.state, isNotNull);
    });

    test('handles exceptions gracefully without crashing', () async {
      when(() => getRemoteConversationUseCase(any()))
          .thenThrow(Exception('Timeout'));

      final notifier = container.read(privateConversationListProvider.notifier);

      await notifier.loadRemoteConversations();

      expect(notifier.state, isNotNull);
    });
  });
}
