import "package:drift/drift.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "../database/app_database.dart";

part "schedule_repository_impl.g.dart";

/// Schedules kept in the local database.
class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Schedule>> watchAll() => _db
      .select(_db.scheduleRows)
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            (
              id: row.id,
              title: row.title,
              description: row.description,
              // drift reads dates back in local time; schedules compare as
              // UTC midnight.
              start: row.startDate.toUtc(),
              end: row.endDate.toUtc(),
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
        ],
      );

  @override
  Future<void> add(ScheduleDraft draft) {
    final now = DateTime.now();

    return _db
        .into(_db.scheduleRows)
        .insert(
          ScheduleRowsCompanion.insert(
            title: draft.title,
            description: draft.description,
            startDate: draft.start,
            endDate: draft.end,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // createdAt is left out, so it keeps the time the schedule was added.
  @override
  Future<void> update(int id, ScheduleDraft draft) =>
      (_db.update(_db.scheduleRows)..where((row) => row.id.equals(id))).write(
        ScheduleRowsCompanion(
          title: Value(draft.title),
          description: Value(draft.description),
          startDate: Value(draft.start),
          endDate: Value(draft.end),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.scheduleRows)..where((row) => row.id.equals(id))).go();
}

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(Ref ref) =>
    ScheduleRepositoryImpl(ref.watch(appDatabaseProvider));
