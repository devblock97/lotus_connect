import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lotus_connect/core/database/tables/app_settings_table.dart';
import 'package:lotus_connect/core/database/tables/conversation_table.dart';
import 'package:lotus_connect/core/database/tables/message_table.dart';

part 'app_database.g.dart';

/// Central database class for Lotus Connect using Drift.
@DriftDatabase(
  tables: [
    ConversationTable,
    MessageTable,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Initializes [AppDatabase] with native executor.
  AppDatabase() : super(_openConnection());

  /// Initializes [AppDatabase] with custom executor for testing.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lotus_connect_db');
  }
}
