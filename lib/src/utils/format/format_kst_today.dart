/// Today in KST (UTC+9, no DST) whatever the device timezone is, as a
/// UTC-midnight date (what schedules and table_calendar work with).
DateTime formatKstToday() {
  final kst = DateTime.now().toUtc().add(const Duration(hours: 9));

  return DateTime.utc(kst.year, kst.month, kst.day);
}
