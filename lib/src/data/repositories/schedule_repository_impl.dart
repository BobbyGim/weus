import "package:drift/drift.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "../database/database.dart";

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
              start: _day(row.startDate),
              end: _day(row.endDate),
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
            startDate: _at(draft.start, now),
            endDate: _at(draft.end, now),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // createdAt is left out, so it keeps the time the schedule was added.
  @override
  Future<void> update(int id, ScheduleDraft draft) {
    final now = DateTime.now();

    return (_db.update(
      _db.scheduleRows,
    )..where((row) => row.id.equals(id))).write(
      ScheduleRowsCompanion(
        title: Value(draft.title),
        description: Value(draft.description),
        startDate: Value(_at(draft.start, now)),
        endDate: Value(_at(draft.end, now)),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.scheduleRows)..where((row) => row.id.equals(id))).go();
}

/// 앱의 날짜(UTC 자정)에 [now]의 시각을 붙인 현지 시간. DB에는 created_at처럼
/// "2026-11-16T23:07:35.706 +09:00"으로 저장된다.
DateTime _at(DateTime day, DateTime now) => DateTime(
  day.year,
  day.month,
  day.day,
  now.hour,
  now.minute,
  now.second,
  now.millisecond,
  now.microsecond,
);

/// DB의 시작·종료 시각 → 앱의 날짜(UTC 자정).
DateTime _day(DateTime at) {
  final local = at.toLocal();

  return DateTime.utc(local.year, local.month, local.day);
}

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(Ref ref) =>
    ScheduleRepositoryImpl(ref.watch(appDatabaseProvider));
