import "package:intl/intl.dart";

// Korean names need initializeDateFormatting("ko_KR"), run in bootstrap().

/// "토"
String formatWeekday(DateTime day) => DateFormat.E("ko_KR").format(day);

/// "11월 15일"
String formatMonthDay(DateTime day) => DateFormat("M월 d일", "ko_KR").format(day);

/// "11월 15일 토요일"
String formatMonthDayWeekday(DateTime day) =>
    DateFormat("M월 d일 EEEE", "ko_KR").format(day);

/// "11월 15일 (토)" in [today]'s year, "2027년 1월 3일 (일)" in any other.
String formatDateLabel(DateTime day, {required DateTime today}) => DateFormat(
  day.year == today.year ? "M월 d일 (E)" : "yyyy년 M월 d일 (E)",
  "ko_KR",
).format(day);

/// "2027. 1. 3 (일)"
String formatDotDate(DateTime day) =>
    DateFormat("yyyy. M. d (E)", "ko_KR").format(day);
