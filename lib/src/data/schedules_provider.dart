import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/domain/domain.dart";

import "repositories/repositories.dart";

part "schedules_provider.g.dart";

/// Every schedule, shared by the calendar and the registration page; follows
/// the local database. 공동일정(Supabase)을 받은 뒤 로컬 일정과 함께 처음 내보내서,
/// 그때까지는 로딩이다. 공동일정이 실패(오프라인)하거나 10초 넘게 걸리면 빠진다.
// shortcut: 공동일정은 앱을 켤 때 한 번만 불러온다, 실행 중 바뀐 것까지 보여야 하면
// Realtime 구독으로.
@Riverpod(keepAlive: true)
class Schedules extends _$Schedules {
  @override
  Stream<List<Schedule>> build() async* {
    final repository = ref.watch(scheduleRepositoryProvider);

    final shared = await repository
        .fetchShared()
        .timeout(const Duration(seconds: 10))
        .catchError((_) => <Schedule>[]);

    yield* repository.watchAll().map((local) => [...shared, ...local]);
  }

  Future<void> add(ScheduleDraft draft) =>
      ref.read(scheduleRepositoryProvider).add(draft);

  // Not update/delete: AsyncNotifier already has an update().
  Future<void> edit(int id, ScheduleDraft draft) =>
      ref.read(scheduleRepositoryProvider).update(id, draft);

  Future<void> remove(int id) =>
      ref.read(scheduleRepositoryProvider).delete(id);
}
