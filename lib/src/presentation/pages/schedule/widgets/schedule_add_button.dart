import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";

import "schedule_add_sheet.dart";

/// Floating "+" that opens the schedule registration sheet, on the calendar
/// and in the day sheet.
class ScheduleAddButton extends StatelessWidget {
  const ScheduleAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      // No Hero: the page and the sheet each show one at the same time.
      heroTag: null,
      tooltip: "일정 등록",
      onPressed: () => showScheduleAddSheet(context),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const CircleBorder(),
      child: const Icon(LucideIcons.plus),
    );
  }
}
