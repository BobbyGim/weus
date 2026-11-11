/// [start] and [end] are UTC-midnight dates, equal for a one-day schedule.
typedef Schedule = ({
  String title,
  String description,
  DateTime start,
  DateTime end,
});

/// Today in KST (UTC+9, no DST) whatever the device timezone is, as the
/// UTC-midnight date schedules and table_calendar work with.
DateTime kstToday() {
  final kst = DateTime.now().toUtc().add(const Duration(hours: 9));

  return DateTime.utc(kst.year, kst.month, kst.day);
}
