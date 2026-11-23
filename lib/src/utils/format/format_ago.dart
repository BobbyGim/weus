import "package:intl/intl.dart";

/// 글 작성 시각: "방금 전", "5분 전", "3시간 전", "어제", 그 전은 "11월 15일"
/// (올해가 아니면 "2025.11.15").
String formatAgo(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();

  final local = time.toLocal();

  final diff = current.difference(local);

  if (diff.inMinutes < 1) return "방금 전";

  if (diff.inHours < 1) return "${diff.inMinutes}분 전";

  final today = DateTime(current.year, current.month, current.day);

  if (!local.isBefore(today)) return "${diff.inHours}시간 전";

  if (!local.isBefore(today.subtract(const Duration(days: 1)))) return "어제";

  return local.year == current.year
      ? DateFormat("M월 d일", "ko_KR").format(local)
      : DateFormat("yyyy.MM.dd", "ko_KR").format(local);
}
