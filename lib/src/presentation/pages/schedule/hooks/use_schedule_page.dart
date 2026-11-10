import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:intl/intl.dart";
import "package:table_calendar/table_calendar.dart";

import "../widgets/schedule_day_cell.dart";
import "../widgets/schedule_sheet.dart";

/// [start] and [end] are UTC-midnight dates, equal for a one-day schedule.
typedef Schedule = ({
  String title,
  String description,
  DateTime start,
  DateTime end,
});

Schedule _november(int day, String title, String description, {int? until}) => (
  title: title,
  description: description,
  start: DateTime.utc(2026, 11, day),
  end: DateTime.utc(2026, 11, until ?? day),
);

// shortcut: sample schedules in memory, move to a repository + ViewModel once they come from the API.
final _schedules = [
  _november(10, "청년부 수련회", "1박 2일, 가평 수양관", until: 11),
  _november(10, "특별 새벽기도", "새벽 5시 30분, 본당", until: 12),
  _november(10, "화요 기도 모임", "저녁 8시, 본당 2층 소예배실"),
  _november(10, "청년부 임원 회의", "기도 모임 후 30분, 다음 달 수련회 준비"),
  _november(10, "찬양팀 연습", "오후 6시, 본당"),
  _november(10, "새가족 환영 준비", "오후 5시, 1층 로비 데코 및 선물 포장"),
  _november(10, "중보기도 모임", "밤 9시 30분, 온라인"),
  _november(15, "주일 예배", "오전 11시, 본당"),
  _november(21, "가을 야외 예배", "오전 10시 교회 앞 집합, 도시락 지참"),
];

bool _isMultiDay(Schedule s) => s.start != s.end;

/// The cell row each multi-day schedule keeps on every day it covers, so its
/// bar stays on one line. Earlier start first, then the longer one; each takes
/// the lowest row not held by a multi-day schedule it overlaps.
final _rows = () {
  final multiDay = _schedules.where(_isMultiDay).toList()
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
}();

/// Schedules covering [day], multi-day ones first.
List<Schedule> _schedulesOn(DateTime day) {
  final covering = [
    for (final s in _schedules)
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
List<ScheduleLabel?> _labelsOn(DateTime day) {
  final covering = _schedulesOn(day);

  final rows = <Schedule?>[];

  for (final s in covering.where(_isMultiDay)) {
    final row = _rows[s]!;

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

/// Today in KST (UTC+9, no DST) whatever the device timezone is, as the
/// UTC-midnight date table_calendar works with.
DateTime _kstToday() {
  final kst = DateTime.now().toUtc().add(const Duration(hours: 9));

  return DateTime.utc(kst.year, kst.month, kst.day);
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
useSchedulePage() {
  final today = _kstToday();

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
        for (final s in _schedulesOn(day))
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
    labelsOn: _labelsOn,
    // First tap selects the day; tapping the selected day opens its schedules.
    onDaySelected: (selected, focused) {
      if (isSameDay(selected, selectedDay.value)) return openSheet(selected);

      selectedDay.value = selected;

      focusedDay.value = focused;
    },
    onPageChanged: (day) => focusedDay.value = day,
  );
}
