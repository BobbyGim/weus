import "../entities/entities.dart";

abstract interface class ScheduleRepository {
  /// Every schedule, emitted again after each change.
  Stream<List<Schedule>> watchAll();

  /// 삭제되지 않은(deleted_at 없는) 공동일정.
  Future<List<Schedule>> fetchShared();

  Future<void> add(ScheduleDraft draft);

  Future<void> update(int id, ScheduleDraft draft);

  Future<void> delete(int id);
}
