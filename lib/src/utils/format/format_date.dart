import "package:intl/intl.dart";

// Korean names need initializeDateFormatting("ko_KR"), run in bootstrap().

/// "토"
String formatWeekday(DateTime day) => DateFormat.E("ko_KR").format(day);

/// "11월 15일"
String formatMonthDay(DateTime day) => DateFormat("M월 d일", "ko_KR").format(day);

/// "11월 15일 토요일"
String formatMonthDayWeekday(DateTime day) =>
    DateFormat("M월 d일 EEEE", "ko_KR").format(day);

/// "2026.11.16 (일)"
String formatDotDate(DateTime day) =>
    DateFormat("yyyy.MM.dd (E)", "ko_KR").format(day);
