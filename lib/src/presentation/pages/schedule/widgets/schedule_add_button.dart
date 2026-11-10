import "package:flutter/material.dart";

/// Floating "+" for registering a schedule, on the calendar and in the day
/// sheet.
class ScheduleAddButton extends StatelessWidget {
  const ScheduleAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      // No Hero: the page and the sheet each show one at the same time.
      heroTag: null,
      tooltip: "일정 등록",
      // shortcut: no registration form yet, wire it here once it exists.
      onPressed: () {},
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}
