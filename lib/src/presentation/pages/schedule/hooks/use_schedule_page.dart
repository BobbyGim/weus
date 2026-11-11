import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:intl/intl.dart";
import "package:table_calendar/table_calendar.dart";

import "package:weus/src/domain/domain.dart";

import "../widgets/schedule_day_cell.dart";
import "../widgets/schedule_sheet.dart";

bool _isMultiDay(Schedule s) => s.start != s.end;

/// The cell row each multi-day schedule keeps on every day it covers, so its
/// bar stays on one line. Earlier start first, then the longer one; each takes
/// the lowest row not held by a multi-day schedule it overlaps.
// shortcut: a record is its own key, so two identical multi-day schedules
// share a row; key by id once schedules come from the API.
Map<Schedule, int> _rowsOf(List<Schedule> schedules) {
  final multiDay = schedules.where(_isMultiDay).toList()
    ..sort((a, b) {
      final byStart = a.start.compareTo(b.start);

      return byStart != 0 ? byStart : b.end.compareTo(a.end);
    });

  final rows = <Schedule, int>{};

  for (final s in multiDay) {
    final taken = {
      for (final MapEntry(key: other, value: row) in rows.entries)
        if (!other.end.isBefore(s.start) && !other.start.isAfter(s.end)) row,
    };

    var row = 0;

    while (taken.contains(row)) {
      row++;
    }

    rows[s] = row;
  }

  return rows;
}

/// Schedules covering [day], multi-day ones first.
List<Schedule> _schedulesOn(List<Schedule> schedules, DateTime day) {
  final covering = [
    for (final s in schedules)
      if (!day.isBefore(s.start) && !day.isAfter(s.end)) s,
  ];

  return [
    ...covering.where(_isMultiDay),
    ...covering.where((s) => !_isMultiDay(s)),
  ];
}

/// What [day]'s cell shows, row by row; null is a row left empty to keep a
/// multi-day bar under it on its own row. One-day schedules fill the free
/// rows in order. For a multi-day schedule the label says which cell of its
/// bar this day is, the bar being the days it covers in this week row (Sunday
/// to Saturday) of this month.
List<ScheduleLabel?> _labelsOn(
  List<Schedule> schedules,
  Map<Schedule, int> multiDayRows,
  DateTime day,
) {
  final covering = _schedulesOn(schedules, day);

  final rows = <Schedule?>[];

  for (final s in covering.where(_isMultiDay)) {
    final row = multiDayRows[s]!;

    while (rows.length <= row) {
      rows.add(null);
    }

    rows[row] = s;
  }

  for (final s in covering.where((s) => !_isMultiDay(s))) {
    final free = rows.indexOf(null);

    free == -1 ? rows.add(s) : rows[free] = s;
  }

  final rowStart = day.subtract(Duration(days: day.weekday % 7));

  final rowEnd = rowStart.add(const Duration(days: 6));

  final monthStart = DateTime.utc(day.year, day.month);

  final monthEnd = DateTime.utc(day.year, day.month + 1, 0);

  DateTime latest(List<DateTime> days) =>
      days.reduce((a, b) => a.isAfter(b) ? a : b);

  DateTime earliest(List<DateTime> days) =>
      days.reduce((a, b) => a.isBefore(b) ? a : b);

  return [
    for (final s in rows)
      if (s == null)
        null
      else
        (
          title: s.title,
          isMultiDay: _isMultiDay(s),
          index: day.difference(latest([s.start, rowStart, monthStart])).inDays,
          span:
              earliest([s.end, rowEnd, monthEnd])
                  .difference(latest([s.start, rowStart, monthStart]))
                  .inDays +
              1,
        ),
  ];
}

/// Calendar starts on, and selects, today's KST date.
({
  DateTime today,
  DateTime focusedDay,
  DateTime selectedDay,
  List<ScheduleLabel?> Function(DateTime day) labelsOn,
  OnDaySelected onDaySelected,
  void Function(DateTime day) onPageChanged,
})
useSchedulePage(List<Schedule> schedules) {
  final today = kstToday();

  final multiDayRows = useMemoized(() => _rowsOf(schedules), [schedules]);

  final selectedDay = useState(today);

  final focusedDay = useState(today);

  final context = useContext();

  final monthDay = DateFormat("M월 d일", "ko_KR");

  void openSheet(DateTime day) => showModalBottomSheet<void>(
    context: context,
    // Over the bottom nav too, not just this tab's navigator.
    useRootNavigator: true,
    // Lets ScheduleSheet set its own height (70% of the screen).
    isScrollControlled: true,
    builder: (_) => ScheduleSheet(
      day: day,
      schedules: [
        for (final s in _schedulesOn(schedules, day))
          (
            title: s.title,
            // A multi-day schedule leads with its date range.
            description: _isMultiDay(s)
                ? "${monthDay.format(s.start)} – ${monthDay.format(s.end)} · ${s.description}"
                : s.description,
          ),
      ],
    ),
  );

  return (
    today: today,
    focusedDay: focusedDay.value,
    selectedDay: selectedDay.value,
    labelsOn: (day) => _labelsOn(schedules, multiDayRows, day),
    // First tap selects the day; tapping the selected day opens its schedules.
    onDaySelected: (selected, focused) {
      if (isSameDay(selected, selectedDay.value)) return openSheet(selected);

      selectedDay.value = selected;

      focusedDay.value = focused;
    },
    onPageChanged: (day) => focusedDay.value = day,
  );
}
