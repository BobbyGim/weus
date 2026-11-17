import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/utils/utils.dart";

import "../schedule_range_dialog.dart";

/// 등록/수정 시트의 폼 상태. 등록은 오늘~오늘(KST)로, 수정은 [initial]의 값으로
/// 시작하고, 제목이 있으면 저장할 수 있다.
({
  TextEditingController title,
  TextEditingController description,
  String startLabel,
  String endLabel,
  bool canSave,
  VoidCallback pickStart,
  VoidCallback pickEnd,
  ScheduleDraft Function() schedule,
})
useScheduleAddSheet(Schedule? initial) {
  final context = useContext();

  final today = useMemoized(formatKstToday);

  final title = useTextEditingController(text: initial?.title);

  final description = useTextEditingController(text: initial?.description);

  final start = useState(initial?.start ?? today);

  final end = useState(initial?.end ?? today);

  // Rebuilds on typing, so the save button follows the title.
  useListenable(title);

  Future<void> pick({required bool pickingEnd}) async {
    final range = await showDialog<({DateTime start, DateTime end})>(
      context: context,
      builder: (_) => ScheduleRangeDialog(
        start: start.value,
        end: end.value,
        pickingEnd: pickingEnd,
      ),
    );

    if (range == null) return;

    start.value = range.start;

    end.value = range.end;
  }

  return (
    title: title,
    description: description,
    startLabel: formatDotDate(start.value),
    endLabel: formatDotDate(end.value),
    canSave: title.text.trim().isNotEmpty,
    pickStart: () => pick(pickingEnd: false),
    pickEnd: () => pick(pickingEnd: true),
    schedule: () => (
      title: title.text.trim(),
      description: description.text.trim(),
      start: start.value,
      end: end.value,
    ),
  );
}
