import "package:drift/drift.dart";

/// A schedule on the calendar. 시작·종료는 고른 날짜 + 저장한 순간의 시각
/// (created_at과 같은 형식), 하루 일정이면 날짜가 같다.
@DataClassName("ScheduleRow")
class ScheduleRows extends Table {
  @override
  String get tableName => "schedules";

  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  /// Set once, when the schedule is added.
  DateTimeColumn get createdAt => dateTime()();

  /// Same as [createdAt] at first, then the time of the last edit.
  DateTimeColumn get updatedAt => dateTime()();
}
