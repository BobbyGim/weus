import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Tracks whether the schedule list still has content below what is showing,
/// from the list's own notifications (first layout and every scroll).
({bool hasMore, bool Function(Notification notification) onListNotification})
useScheduleSheet() {
  final hasMore = useState(false);

  return (
    hasMore: hasMore.value,
    onListNotification: (notification) {
      final metrics = switch (notification) {
        ScrollMetricsNotification(:final metrics) => metrics,
        ScrollNotification(:final metrics) => metrics,
        _ => null,
      };

      if (metrics != null) hasMore.value = metrics.extentAfter > 1;

      return false;
    },
  );
}
