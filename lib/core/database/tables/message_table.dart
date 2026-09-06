import 'package:drift/drift.dart';
import 'package:lotus_connect/core/database/tables/conversation_table.dart';

/// Drift table schema for chat messages.
class MessageTable extends Table {
  /// Message primary key.
  TextColumn get id => text()();

  /// Foreign key referencing [ConversationTable.id].
  TextColumn get conversationId =>
      text().references(ConversationTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get senderRole => text()();

  TextColumn get content => text()();

  DateTimeColumn get timestamp => dateTime()();

  BoolColumn get isError => boolean().withDefault(const Constant(false))();

  /// Detailed status string: 'sending', 'sent', 'streaming', 'failed'.
  TextColumn get status => text().withDefault(const Constant('sent'))();

  TextColumn get replyToId => text().nullable()();

  TextColumn get mediaUrl => text().nullable()();

  TextColumn get thumbnailUrl => text().nullable()();

  TextColumn get fileName => text().nullable()();

  IntColumn get fileSize => integer().nullable()();

  TextColumn get mimeType => text().nullable()();

  IntColumn get duration => integer().nullable()();

  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();

  TextColumn get reactions => text().nullable()();

  TextColumn get medias => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
