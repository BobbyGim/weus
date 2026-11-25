import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";
import "package:weus/src/utils/utils.dart";

import "../schedule_range_dialog.dart";

/// 등록/수정 시트의 폼 상태. 등록은 오늘~오늘(KST)로, 수정은 [initial]의 값으로
/// 시작하고, 제목이 있으면 저장할 수 있다. [editing]이면 수정 모드.
/// [save]는 로컬 DB에 등록(수정)하고 스낵바를 띄운 뒤 시트를 닫는다.
({
  bool editing,
  TextEditingController title,
  TextEditingController description,
  String startLabel,
  String endLabel,
  bool canSave,
  VoidCallback pickStart,
  VoidCallback pickEnd,
  VoidCallback save,
  VoidCallback close,
})
useScheduleAddSheet(WidgetRef ref, Schedule? initial) {
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

  void save() {
    final schedules = ref.read(schedulesProvider.notifier);

    final draft = (
      title: title.text.trim(),
      description: description.text.trim(),
      start: start.value,
      end: end.value,
    );

    if (initial == null) {
      schedules.add(draft);
    } else {
      schedules.edit(initial.id, draft);
    }

    showAppSnackBar(
      context,
      initial == null ? "일정을 등록했어요" : "일정을 수정했어요",
      icon: LucideIcons.circleCheck,
    );

    Navigator.of(context).pop();
  }

  return (
    editing: initial != null,
    title: title,
    description: description,
    startLabel: formatDotDate(start.value),
    endLabel: formatDotDate(end.value),
    canSave: title.text.trim().isNotEmpty,
    pickStart: () => pick(pickingEnd: false),
    pickEnd: () => pick(pickingEnd: true),
    save: save,
    close: Navigator.of(context).pop,
  );
}
