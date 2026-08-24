import 'package:drift/drift.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chat_core/domain/entities/message.dart';

abstract class ChatCoreLocalDataSource {
  Stream<List<Conversation>> watchConversations();
  Future<List<Conversation>> getConversations();
  Stream<List<Message>> watchMessages(String conversationId);
  Future<Conversation> createConversation({
    required String title,
    String? modelName,
    bool isUserToUser = false,
    String peerId = '',
    String? id,
  });
  Future<void> renameConversation(String conversationId, String newTitle);
  Future<void> deleteConversation(String conversationId);
  Future<void> togglePinConversation(String conversationId);
  Future<void> toggleFavouriteConversation(String conversationId);
  Future<void> saveDraftMessage(String conversationId, String draft);
  Future<void> saveMessage(Message message);
  Future<void> deleteMessage(String messageId);
  Future<List<Message>> getLocalMessages(String conversationId);
  Future<Message?> getMessage(String messageId);
  Future<void> markOutgoingMessagesAsRead(
    String conversationId,
    DateTime timestamp,
  );
}

class ChatCoreLocalDataSourceImpl implements ChatCoreLocalDataSource {
  ChatCoreLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Conversation>> watchConversations() {
    return _db.select(_db.conversationTable).watch().map(
          (rows) => rows
              .map(
                (row) => Conversation(
                  id: row.id,
                  title: row.title,
                  createdAt: row.createdAt,
                  updatedAt: row.updatedAt,
                  isPinned: row.isPinned,
                  isFavourite: row.isFavourite,
                  modelName: row.modelName,
                  draftMessage: row.draftMessage,
                  systemPrompt: row.systemPrompt,
                  isUserToUser: row.isUserToUser,
                  peerId: row.peerId,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<Conversation>> getConversations() async {
    final rows = await _db.select(_db.conversationTable).get();
    return rows
        .map(
          (row) => Conversation(
            id: row.id,
            title: row.title,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            isPinned: row.isPinned,
            isFavourite: row.isFavourite,
            modelName: row.modelName,
            draftMessage: row.draftMessage,
            systemPrompt: row.systemPrompt,
            isUserToUser: row.isUserToUser,
            peerId: row.peerId,
          ),
        )
        .toList();
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final query = _db.select(_db.messageTable)
      ..where((tbl) => tbl.conversationId.equals(conversationId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => Message(
                  id: row.id,
                  conversationId: row.conversationId,
                  role: MessageRole.values.firstWhere(
                    (e) => e.name == row.senderRole,
                    orElse: () => MessageRole.assistant,
                  ),
                  content: row.content,
                  timestamp: row.timestamp,
                  isError: row.isError,
                  status: MessageStatus.values.firstWhere(
                    (e) => e.name == row.status,
                    orElse: () => MessageStatus.sent,
                  ),
                  replyToId: row.replyToId,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<Conversation> createConversation({
    required String title,
    String? modelName,
    bool isUserToUser = false,
    String peerId = '',
    String? id,
  }) async {
    final now = DateTime.now();
    final conversationId = id ?? now.millisecondsSinceEpoch.toString();
    final conversation = Conversation(
      id: conversationId,
      title: title,
      createdAt: now,
      updatedAt: now,
      modelName: modelName ?? 'gemini-1.5-flash',
      isUserToUser: isUserToUser,
      peerId: peerId,
    );

    await _db.into(_db.conversationTable).insert(
          ConversationTableCompanion.insert(
            id: conversation.id,
            title: conversation.title,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            modelName: Value(conversation.modelName),
            isUserToUser: Value(conversation.isUserToUser),
            peerId: Value(conversation.peerId),
          ),
        );
    return conversation;
  }

  @override
  Future<void> renameConversation(
    String conversationId,
    String newTitle,
  ) async {
    await (_db.update(_db.conversationTable)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(
      ConversationTableCompanion(
        title: Value(newTitle),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await (_db.delete(_db.conversationTable)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .go();
  }

  @override
  Future<void> togglePinConversation(String conversationId) async {
    final current = await (_db.select(_db.conversationTable)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .getSingleOrNull();

    if (current != null) {
      await (_db.update(_db.conversationTable)
            ..where((tbl) => tbl.id.equals(conversationId)))
          .write(
        ConversationTableCompanion(
          isPinned: Value(!current.isPinned),
        ),
      );
    }
  }

  @override
  Future<void> toggleFavouriteConversation(String conversationId) async {
    final current = await (_db.select(_db.conversationTable)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .getSingleOrNull();

    if (current != null) {
      await (_db.update(_db.conversationTable)
            ..where((tbl) => tbl.id.equals(conversationId)))
          .write(
        ConversationTableCompanion(
          isFavourite: Value(!current.isFavourite),
        ),
      );
    }
  }

  @override
  Future<void> saveDraftMessage(String conversationId, String draft) async {
    await (_db.update(_db.conversationTable)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(
      ConversationTableCompanion(
        draftMessage: Value(draft),
      ),
    );
  }

  @override
  Future<void> saveMessage(Message message) async {
    await _db.into(_db.messageTable).insertOnConflictUpdate(
          MessageTableCompanion.insert(
            id: message.id,
            conversationId: message.conversationId,
            senderRole: message.role.name,
            content: message.content,
            timestamp: message.timestamp,
            isError: Value(message.isError),
            status: Value(message.status.name),
            replyToId: Value(message.replyToId),
          ),
        );
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await (_db.delete(_db.messageTable)..where((t) => t.id.equals(messageId)))
        .go();
  }

  @override
  Future<List<Message>> getLocalMessages(String conversationId) async {
    final query = _db.select(_db.messageTable)
      ..where((tbl) => tbl.conversationId.equals(conversationId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => Message(
            id: row.id,
            conversationId: row.conversationId,
            role: MessageRole.values.firstWhere(
              (e) => e.name == row.senderRole,
              orElse: () => MessageRole.assistant,
            ),
            content: row.content,
            timestamp: row.timestamp,
            isError: row.isError,
            status: MessageStatus.values.firstWhere(
              (e) => e.name == row.status,
              orElse: () => MessageStatus.sent,
            ),
            replyToId: row.replyToId,
          ),
        )
        .toList();
  }

  @override
  Future<Message?> getMessage(String messageId) async {
    final query = _db.select(_db.messageTable)
      ..where((tbl) => tbl.id.equals(messageId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return Message(
      id: row.id,
      conversationId: row.conversationId,
      role: MessageRole.values.firstWhere(
        (e) => e.name == row.senderRole,
        orElse: () => MessageRole.assistant,
      ),
      content: row.content,
      timestamp: row.timestamp,
      isError: row.isError,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => MessageStatus.sent,
      ),
      replyToId: row.replyToId,
    );
  }

  @override
  Future<void> markOutgoingMessagesAsRead(
    String conversationId,
    DateTime timestamp,
  ) async {
    await (_db.update(_db.messageTable)
          ..where((tbl) => tbl.conversationId.equals(conversationId))
          ..where((tbl) => tbl.timestamp.isSmallerOrEqualValue(timestamp)))
        .write(
      MessageTableCompanion(
        status: Value(MessageStatus.read.name),
      ),
    );
  }
}
