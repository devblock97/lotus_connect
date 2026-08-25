import 'package:drift/drift.dart';
import 'package:lotus_connect/core/database/tables/conversation_table.dart';

/// Drift table schema for chat messages.
class MessageTable extends Table {
  /// Message primary key.
  TextColumn get id => text()();

  /// Foreign key referencing [ConversationTable.id].
  TextColumn get conversationId =>
      text().references(ConversationTable, #id, onDelete: KeyAction.cascade)();

  /// Sender role: 'user', 'assistant', 'system'.
  TextColumn get senderRole => text()();

  /// Text content of message.
  TextColumn get content => text()();

  /// Message timestamp.
  DateTimeColumn get timestamp => dateTime()();

  /// Error status flag.
  BoolColumn get isError => boolean().withDefault(const Constant(false))();

  /// Detailed status string: 'sending', 'sent', 'streaming', 'failed'.
  TextColumn get status => text().withDefault(const Constant('sent'))();

  /// Nullable ID of the message this message is replying to.
  TextColumn get replyToId => text().nullable()();

  /// Nullable media URL.
  TextColumn get mediaUrl => text().nullable()();

  /// Nullable thumbnail URL.
  TextColumn get thumbnailUrl => text().nullable()();

  /// Nullable file name.
  TextColumn get fileName => text().nullable()();

  /// Nullable file size.
  IntColumn get fileSize => integer().nullable()();

  /// Nullable MIME type.
  TextColumn get mimeType => text().nullable()();

  /// Nullable duration.
  IntColumn get duration => integer().nullable()();

  /// Flag indicating if the message was edited.
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();

  /// Nullable string containing serialized reactions.
  TextColumn get reactions => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
