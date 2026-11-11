import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:table_calendar/table_calendar.dart";

import "package:weus/src/domain/domain.dart";

/// Range picking of the period dialog. It opens showing the current period;
/// the first tap starts a new one and the second tap closes the dialog with
/// the two days in order (the same day twice is a one-day period).
({
  DateTime today,
  DateTime focusedDay,
  DateTime start,
  DateTime? end,
  OnDaySelected onDaySelected,
  void Function(DateTime day) onPageChanged,
})
useScheduleRangeDialog(DateTime initialStart, DateTime initialEnd) {
  final context = useContext();

  final today = useMemoized(kstToday);

  final start = useState(initialStart);

  final end = useState<DateTime?>(initialEnd);

  final focusedDay = useState(initialStart);

  void onDaySelected(DateTime day, DateTime focused) {
    // A whole period is showing: this tap is the start of a new one.
    if (end.value != null) {
      start.value = day;

      end.value = null;

      focusedDay.value = focused;

      return;
    }

    final first = start.value;

    Navigator.of(context).pop(
      day.isBefore(first) ? (start: day, end: first) : (start: first, end: day),
    );
  }

  return (
    today: today,
    focusedDay: focusedDay.value,
    start: start.value,
    end: end.value,
    onDaySelected: onDaySelected,
    onPageChanged: (day) => focusedDay.value = day,
  );
}
