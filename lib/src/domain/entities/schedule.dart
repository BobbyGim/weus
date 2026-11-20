/// What the user fills in for a schedule. [start] and [end] are UTC-midnight
/// dates, equal for a one-day schedule.
typedef ScheduleDraft = ({
  String title,
  String description,
  DateTime start,
  DateTime end,
});

/// A saved schedule: a [ScheduleDraft] plus what the storage adds.
/// [updatedAt] equals [createdAt] until the schedule is edited.
/// [isShared]: Supabase에서 불러온 공동일정 (읽기 전용, id는 로컬 일정과 겹칠 수 있다).
typedef Schedule = ({
  int id,
  bool isShared,
  String title,
  String description,
  DateTime start,
  DateTime end,
  DateTime createdAt,
  DateTime updatedAt,
});
