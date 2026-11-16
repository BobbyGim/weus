import "package:drift/drift.dart";

/// A schedule on the calendar; the dates are UTC midnight, equal for a
/// one-day schedule.
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
