import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:table_calendar/table_calendar.dart";

import "../widgets/schedule_sheet.dart";

typedef Schedule = ({String title, String description});

// shortcut: sample schedules in memory, move to a repository + ViewModel once they come from the API.
final _schedules = <DateTime, List<Schedule>>{
  DateTime.utc(2026, 11, 10): [
    (title: "화요 기도 모임", description: "저녁 8시, 본당 2층 소예배실"),
    (title: "청년부 임원 회의", description: "기도 모임 후 30분, 다음 달 수련회 준비"),
    (title: "찬양팀 연습", description: "오후 6시, 본당"),
    (title: "새가족 환영 준비", description: "오후 5시, 1층 로비 데코 및 선물 포장"),
    (title: "중보기도 모임", description: "밤 9시 30분, 온라인"),
  ],
  DateTime.utc(2026, 11, 15): [(title: "주일 예배", description: "오전 11시, 본당")],
  DateTime.utc(2026, 11, 21): [
    (title: "가을 야외 예배", description: "오전 10시 교회 앞 집합, 도시락 지참"),
  ],
};

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
  List<Schedule> Function(DateTime day) schedulesOn,
  OnDaySelected onDaySelected,
  void Function(DateTime day) onPageChanged,
})
useSchedulePage() {
  final today = _kstToday();

  final selectedDay = useState(today);

  final focusedDay = useState(today);

  final context = useContext();

  void openSheet(DateTime day) => showModalBottomSheet<void>(
    context: context,
    // Over the bottom nav too, not just this tab's navigator.
    useRootNavigator: true,
    // Always opens full height, up to just under the status bar.
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        ScheduleSheet(day: day, schedules: _schedules[day] ?? const []),
  );

  return (
    today: today,
    focusedDay: focusedDay.value,
    selectedDay: selectedDay.value,
    schedulesOn: (day) => _schedules[day] ?? const [],
    // First tap selects the day; tapping the selected day opens its schedules.
    onDaySelected: (selected, focused) {
      if (isSameDay(selected, selectedDay.value)) return openSheet(selected);

      selectedDay.value = selected;

      focusedDay.value = focused;
    },
    onPageChanged: (day) => focusedDay.value = day,
  );
}
