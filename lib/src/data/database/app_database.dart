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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 only ever existed on development devices: start over rather than
      // invent created/updated times for its rows.
      if (from < 2) {
        await m.deleteTable(scheduleRows.actualTableName);

        await m.createTable(scheduleRows);

        return;
      }

      // v5: 날짜를 Unix 초(INTEGER)에서 읽을 수 있는 TEXT로 바꾼다. 기존 시작·종료는
      // 시각이 없어서 그날 한국 시간 00:00, 등록·수정 시각은 "+09:00"이 붙은 한국 시간.
      // v3(숫자와 문자열이 섞임)·v4(날짜만)도 와서 값의 형태별로 변환한다.
      if (from < 5) {
        String name(GeneratedColumn<Object> column) =>
            column.escapedNameFor(SqlDialect.sqlite);

        Expression<String> kstDate(GeneratedColumn<Object> column) =>
            CustomExpression(
              "CASE WHEN typeof(${name(column)}) = 'integer' "
              "THEN date(${name(column)}, 'unixepoch') "
              "ELSE substr(${name(column)}, 1, 10) END "
              "|| 'T00:00:00.000 +09:00'",
            );

        Expression<String> kstTime(
          GeneratedColumn<Object> column,
        ) => CustomExpression(
          "CASE WHEN typeof(${name(column)}) = 'integer' "
          "THEN strftime('%Y-%m-%dT%H:%M:%f', ${name(column)}, 'unixepoch', '+9 hours') || ' +09:00' "
          "ELSE ${name(column)} END",
        );

        await m.alterTable(
          TableMigration(
            scheduleRows,
            columnTransformer: {
              scheduleRows.startDate: kstDate(scheduleRows.startDate),
              scheduleRows.endDate: kstDate(scheduleRows.endDate),
              scheduleRows.createdAt: kstTime(scheduleRows.createdAt),
              scheduleRows.updatedAt: kstTime(scheduleRows.updatedAt),
            },
          ),
        );
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
