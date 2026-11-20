import "package:cupertino_ui/cupertino_ui.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

/// Tracks whether the schedule list still has content below what is showing,
/// from the list's own notifications (first layout and every scroll).
/// [schedules]는 시트를 열 때의 목록이라, 여기서 지운 로컬 일정은 직접 뺀다.
/// [onDelete]는 아래에서 올라오는 액션시트로 정말 지울지 물어보고 확인하면 로컬 DB에서 지운다.
({
  bool hasMore,
  bool Function(Notification notification) onListNotification,
  List<Schedule> schedules,
  void Function(Schedule schedule) onDelete,
})
useScheduleSheet(WidgetRef ref, List<Schedule> schedules) {
  final context = useContext();

  final hasMore = useState(false);

  // 지운 로컬 일정의 id (공동일정 id와 겹칠 수 있어 로컬만 비교한다).
  final deleted = useState(<int>{});

  Future<void> delete(Schedule schedule) async {
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        message: const Text("삭제한 일정은 되돌릴 수 없어요. 삭제하시겠습니까?"),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("삭제"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("취소"),
        ),
      ),
    );

    if (confirmed != true) return;

    await ref.read(schedulesProvider.notifier).remove(schedule.id);

    deleted.value = {...deleted.value, schedule.id};
  }

  return (
    hasMore: hasMore.value,
    onListNotification: (notification) {
      final metrics = switch (notification) {
        ScrollMetricsNotification(:final metrics) => metrics,
        ScrollNotification(:final metrics) => metrics,
        _ => null,
      };

      if (metrics != null) hasMore.value = metrics.extentAfter > 1;

      return false;
    },
    schedules: [
      for (final s in schedules)
        if (s.isShared || !deleted.value.contains(s.id)) s,
    ],
    onDelete: delete,
  );
}
