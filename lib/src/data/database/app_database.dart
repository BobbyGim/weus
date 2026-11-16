import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "tables/schedule_rows.dart";

part "app_database.g.dart";

/// The app's local SQLite database, a `weus.sqlite` file in the app's
/// documents (each flavor is its own app, so its own file).
/// Tables live in `tables/`, one file each; list new ones in [DriftDatabase].
/// After changing a table: bump [schemaVersion] and add the migration.
@DriftDatabase(tables: [ScheduleRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: "weus"));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 only ever existed on development devices: start over rather than
      // invent created/updated times for its rows.
      if (from < 2) {
        await m.deleteTable(scheduleRows.actualTableName);

        await m.createTable(scheduleRows);
      }
    },
  );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();

  ref.onDispose(db.close);

  return db;
}
