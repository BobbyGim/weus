import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:table_calendar/table_calendar.dart";

import "package:weus/src/utils/utils.dart";

/// 기간 다이얼로그에서 날짜 하나 고르기. [pickingEnd]가 false면 시작일, true면
/// 종료일을 바꾼다. 누르는 즉시 `(start: …, end: …)`로 닫힌다.
/// 시작일을 종료일 뒤로 옮기면 종료일도 같은 날로 따라가고, 종료일은 시작일
/// 이전 날을 고를 수 없다.
({
  DateTime today,
  DateTime focusedDay,
  OnDaySelected onDaySelected,
  void Function(DateTime day) onPageChanged,
  bool Function(DateTime day) isEnabled,
})
useScheduleRangeDialog(
  DateTime start,
  DateTime end, {
  required bool pickingEnd,
}) {
  final context = useContext();

  final today = useMemoized(formatKstToday);

  final focusedDay = useState(pickingEnd ? end : start);

  void onDaySelected(DateTime day, DateTime _) => Navigator.of(context).pop(
    pickingEnd
        ? (start: start, end: day)
        : (start: day, end: day.isAfter(end) ? day : end),
  );

  return (
    today: today,
    focusedDay: focusedDay.value,
    onDaySelected: onDaySelected,
    onPageChanged: (day) => focusedDay.value = day,
    isEnabled: (day) => !pickingEnd || !day.isBefore(start),
  );
}
