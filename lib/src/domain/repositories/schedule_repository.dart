import "../entities/schedule.dart";

abstract interface class ScheduleRepository {
  /// Every schedule, emitted again after each change.
  Stream<List<Schedule>> watchAll();

  Future<void> add(ScheduleDraft draft);

  Future<void> update(int id, ScheduleDraft draft);

  Future<void> delete(int id);
}
