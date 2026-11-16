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
typedef Schedule = ({
  int id,
  String title,
  String description,
  DateTime start,
  DateTime end,
  DateTime createdAt,
  DateTime updatedAt,
});
