import 'package:drift/drift.dart';

/// Drift table schema for storing chat conversations.
class ConversationTable extends Table {
  /// Unique identifier for the conversation.
  TextColumn get id => text()();

  /// Title of the conversation.
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Timestamp when created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// Whether the conversation is pinned.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// Whether the conversation is marked as favourite.
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  /// Selected AI model for this conversation.
  TextColumn get modelName => text().withDefault(const Constant('gemini-1.5-pro'))();

  /// Unsaved draft message input text.
  TextColumn get draftMessage => text().nullable()();

  /// Optional custom system prompt for this conversation.
  TextColumn get systemPrompt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
