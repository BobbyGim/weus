import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

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
      onPressed: () {
        // Over the bottom nav too; its context outlives the day sheet.
        final root = Navigator.of(context, rootNavigator: true);

        // In the day sheet: close it first, its list would be out of date
        // after a save.
        if (ModalRoute.of(context) is PopupRoute) root.pop();

        showModalBottomSheet<void>(
          context: root.context,
          // Lets ScheduleAddSheet set its own height (90% of the screen).
          isScrollControlled: true,
          builder: (_) => const ScheduleAddSheet(),
        );
      },
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const CircleBorder(),
      child: const Icon(LucideIcons.plus),
    );
  }
}
