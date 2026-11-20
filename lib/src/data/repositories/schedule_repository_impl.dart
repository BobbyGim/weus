import "package:drift/drift.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:weus/src/domain/domain.dart";

import "../database/database.dart";
import "../supabase/supabase.dart";

part "schedule_repository_impl.g.dart";

/// Schedules kept in the local database, plus the shared ones in Supabase.
class ScheduleRepositoryImpl implements ScheduleRepository {
  const ScheduleRepositoryImpl(this._db, this._supabase);

  final AppDatabase _db;

  final SupabaseClient _supabase;

  @override
  Stream<List<Schedule>> watchAll() => _db
      .select(_db.scheduleRows)
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            (
              id: row.id,
              isShared: false,
              title: row.title,
              description: row.description,
              start: _day(row.startDate),
              end: _day(row.endDate),
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
        ],
      );

  // start_date·end_date는 date 컬럼이라 "2026-11-19"로 온다.
  @override
  Future<List<Schedule>> fetchShared() async {
    final rows = await _supabase
        .from("schedules")
        .select()
        .isFilter("deleted_at", null);

    return [
      for (final row in rows)
        (
          id: row["id"] as int,
          isShared: true,
          title: row["title"] as String,
          description: row["description"] as String,
          start: _utcDate(row["start_date"] as String),
          end: _utcDate(row["end_date"] as String),
          createdAt: DateTime.parse(row["created_at"] as String),
          updatedAt: DateTime.parse(row["updated_at"] as String),
        ),
    ];
  }

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

/// "2026-11-19" → 앱의 날짜(UTC 자정).
DateTime _utcDate(String date) => DateTime.parse("${date}T00:00:00Z");

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(Ref ref) => ScheduleRepositoryImpl(
  ref.watch(appDatabaseProvider),
  ref.watch(supabaseProvider),
);
