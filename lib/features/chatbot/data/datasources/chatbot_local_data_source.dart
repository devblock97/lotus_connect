import 'package:drift/drift.dart';
import 'package:lotus_connect/app/theme/app_theme.dart';
import 'package:lotus_connect/core/database/app_database.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/app_settings.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/conversation.dart';
import 'package:lotus_connect/features/chatbot/domain/entities/message.dart';

/// Local data source interface using Drift SQLite database.
abstract class ChatbotLocalDataSource {
  Stream<List<Conversation>> watchConversations();
  Future<List<Conversation>> getConversations();
  Stream<List<Message>> watchMessages(String conversationId);
  Future<Conversation> createConversation(
      {required String title, String? modelName});
  Future<void> renameConversation(String conversationId, String newTitle);
  Future<void> deleteConversation(String conversationId);
  Future<void> togglePinConversation(String conversationId);
  Future<void> toggleFavouriteConversation(String conversationId);
  Future<void> saveDraftMessage(String conversationId, String draft);
  Future<void> saveMessage(Message message);
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
}

/// Concrete implementation of [ChatbotLocalDataSource] via Drift database.
class ChatbotLocalDataSourceImpl implements ChatbotLocalDataSource {
  ChatbotLocalDataSourceImpl(this._db);

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
                ),
              )
              .toList(),
        );
  }

  @override
  Future<Conversation> createConversation({
    required String title,
    String? modelName,
  }) async {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    final conversation = Conversation(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
      modelName: modelName ?? 'gemini-1.5-flash',
    );

    await _db.into(_db.conversationTable).insert(
          ConversationTableCompanion.insert(
            id: conversation.id,
            title: conversation.title,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            modelName: Value(conversation.modelName),
          ),
        );
    return conversation;
  }

  @override
  Future<void> renameConversation(
      String conversationId, String newTitle) async {
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
          ),
        );
  }

  @override
  Future<AppSettings> getSettings() async {
    final row = await (_db.select(_db.appSettingsTable)
          ..where((tbl) => tbl.id.equals('default')))
        .getSingleOrNull();

    if (row == null) return const AppSettings();

    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == row.themeMode,
      orElse: () => AppThemeMode.dark,
    );

    return AppSettings(
      themeMode: themeMode,
      languageCode: row.languageCode,
      activeAiProvider: row.activeAiProvider,
      activeAiModel: row.activeAiModel,
      geminiApiKey: row.geminiApiKey,
      localLlmBaseUrl: row.localLlmBaseUrl,
      systemPrompt: row.systemPrompt,
    );
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _db.into(_db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            id: 'default',
            themeMode: Value(settings.themeMode.name),
            languageCode: Value(settings.languageCode),
            activeAiProvider: Value(settings.activeAiProvider),
            activeAiModel: Value(settings.activeAiModel),
            geminiApiKey: Value(settings.geminiApiKey),
            localLlmBaseUrl: Value(settings.localLlmBaseUrl),
            systemPrompt: Value(settings.systemPrompt),
          ),
        );
  }
}
