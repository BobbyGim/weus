import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:intl/intl.dart";

import "package:weus/src/domain/domain.dart";

/// Form state of the registration sheet. The period starts as today to today
/// (KST); the schedule can be saved once it has a title.
({
  TextEditingController title,
  TextEditingController description,
  String startLabel,
  String endLabel,
  bool canSave,
  VoidCallback pickDates,
  Schedule Function() schedule,
})
useScheduleAddSheet() {
  final context = useContext();

  final today = useMemoized(kstToday);

  final title = useTextEditingController();

  final description = useTextEditingController();

  final start = useState(today);

  final end = useState(today);

  // Rebuilds on typing, so the save button follows the title.
  useListenable(title);

  // The year shows only when it is not this year.
  String label(DateTime day) => DateFormat(
    day.year == today.year ? "M월 d일 (E)" : "yyyy. M. d (E)",
    "ko_KR",
  ).format(day);

  Future<void> pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      // Same span as the calendar.
      firstDate: DateTime.utc(2020),
      lastDate: DateTime.utc(2035, 12, 31),
      currentDate: today,
      initialDateRange: DateTimeRange(start: start.value, end: end.value),
      helpText: "기간 선택",
      saveText: "확인",
    );

    if (range == null) return;

    // The picker answers in local time; schedules are UTC-midnight dates.
    DateTime utc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

    start.value = utc(range.start);

    end.value = utc(range.end);
  }

  return (
    title: title,
    description: description,
    startLabel: label(start.value),
    endLabel: label(end.value),
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
