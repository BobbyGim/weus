import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:table_calendar/table_calendar.dart";

import "package:weus/src/presentation/theme/theme.dart";

import "hooks/use_schedule_range_dialog.dart";

/// Dialog that picks a schedule's period: only a month calendar and a close
/// button. It pops with `(start: …, end: …)` as soon as the second day is
/// tapped, or with nothing when closed.
class ScheduleRangeDialog extends HookWidget {
  const ScheduleRangeDialog({
    super.key,
    required this.start,
    required this.end,
  });

  final DateTime start;

  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final range = useScheduleRangeDialog(start, end);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final weekdayStyle = text.labelSmall!.copyWith(color: AppColors.gray400);

    final edge = BoxDecoration(color: scheme.primary, shape: BoxShape.circle);

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TableCalendar(
                locale: "ko_KR",
                // Same span as the calendar page.
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: range.focusedDay,
                currentDay: range.today,
                rangeStartDay: range.start,
                rangeEndDay: range.end,
                onDaySelected: range.onDaySelected,
                onPageChanged: range.onPageChanged,
                availableCalendarFormats: const {CalendarFormat.month: ""},
                weekendDays: const [DateTime.sunday],
                rowHeight: 44,
                daysOfWeekHeight: 32,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: text.titleMedium!,
                  leftChevronIcon: Icon(
                    LucideIcons.chevronLeft,
                    color: scheme.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    LucideIcons.chevronRight,
                    color: scheme.onSurface,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: weekdayStyle,
                  weekendStyle: weekdayStyle.copyWith(color: scheme.error),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: text.bodyMedium!,
                  weekendTextStyle: text.bodyMedium!.copyWith(
                    color: scheme.error,
                  ),
                  withinRangeTextStyle: text.bodyMedium!,
                  rangeHighlightColor: scheme.primaryContainer,
                  rangeStartDecoration: edge,
                  rangeEndDecoration: edge,
                  rangeStartTextStyle: text.bodyMedium!.copyWith(
                    color: scheme.onPrimary,
                  ),
                  rangeEndTextStyle: text.bodyMedium!.copyWith(
                    color: scheme.onPrimary,
                  ),
                  // Today keeps a blue ring, as on the calendar page.
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.primary, width: 1.5),
                  ),
                  todayTextStyle: text.bodyMedium!.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // A filled button would touch the dialog's edge without this.
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                child: FilledButton(
                  onPressed: Navigator.of(context).pop,
                  // Secondary action: neutral gray, not the brand color.
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.surfaceContainerHigh,
                    foregroundColor: scheme.onSurface,
                  ),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
