import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/utils/utils.dart";

import "../schedule_range_dialog.dart";

/// Form state of the registration sheet. The period starts as today to today
/// (KST); the schedule can be saved once it has a title.
({
  TextEditingController title,
  TextEditingController description,
  String startLabel,
  String endLabel,
  bool canSave,
  VoidCallback pickDates,
  ScheduleDraft Function() schedule,
})
useScheduleAddSheet() {
  final context = useContext();

  final today = useMemoized(formatKstToday);

  final title = useTextEditingController();

  final description = useTextEditingController();

  final start = useState(today);

  final end = useState(today);

  // Rebuilds on typing, so the save button follows the title.
  useListenable(title);

  Future<void> pickDates() async {
    final range = await showDialog<({DateTime start, DateTime end})>(
      context: context,
      builder: (_) => ScheduleRangeDialog(start: start.value, end: end.value),
    );

    if (range == null) return;

    start.value = range.start;

    end.value = range.end;
  }

  return (
    title: title,
    description: description,
    startLabel: formatDateLabel(start.value, today: today),
    endLabel: formatDateLabel(end.value, today: today),
    canSave: title.text.trim().isNotEmpty,
    pickDates: pickDates,
    schedule: () => (
      title: title.text.trim(),
      description: description.text.trim(),
      start: start.value,
      end: end.value,
    ),
  );
}
