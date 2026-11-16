import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/schedule_repository_impl.dart";

part "schedules_provider.g.dart";

/// Every schedule, shared by the calendar and the registration page; follows
/// the local database.
@Riverpod(keepAlive: true)
class Schedules extends _$Schedules {
  @override
  Stream<List<Schedule>> build() =>
      ref.watch(scheduleRepositoryProvider).watchAll();

  Future<void> add(ScheduleDraft draft) =>
      ref.read(scheduleRepositoryProvider).add(draft);

  // Not update/delete: AsyncNotifier already has an update().
  Future<void> edit(int id, ScheduleDraft draft) =>
      ref.read(scheduleRepositoryProvider).update(id, draft);

  Future<void> remove(int id) =>
      ref.read(scheduleRepositoryProvider).delete(id);
}
