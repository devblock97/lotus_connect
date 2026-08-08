import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lotus_connect/app/config/app_config.dart';
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
  int get schemaVersion => 8; // Incremented schema version for replyToId column

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Destructive upgrade strategy for development phase
          // to avoid schema mismatch
          if (from < to) {
            for (final table in allTables) {
              await m.deleteTable(table.actualTableName);
            }
            await m.createAll();
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lotus_connect_db');
  }
}
