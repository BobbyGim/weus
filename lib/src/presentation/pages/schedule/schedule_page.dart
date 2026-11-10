import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:intl/intl.dart";
import "package:table_calendar/table_calendar.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "hooks/use_schedule_page.dart";
import "widgets/schedule_add_button.dart";
import "widgets/schedule_day_cell.dart";

class SchedulePage extends HookWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = useSchedulePage();

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final weekdayStyle = text.labelSmall!.copyWith(color: AppColors.gray400);

    final calendar = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TableCalendar(
        locale: "ko_KR",
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: schedule.focusedDay,
        currentDay: schedule.today,
        selectedDayPredicate: (day) => isSameDay(day, schedule.selectedDay),
        onDaySelected: schedule.onDaySelected,
        onPageChanged: schedule.onPageChanged,
        availableCalendarFormats: const {CalendarFormat.month: ""},
        weekendDays: const [DateTime.sunday],
        // The 6 week rows share all the height the page has, in every
        // month.
        shouldFillViewport: true,
        sixWeekMonthsEnforced: true,
        daysOfWeekHeight: 32,
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: text.titleLarge!,
          leftChevronIcon: Icon(Icons.chevron_left, color: scheme.onSurface),
          rightChevronIcon: Icon(Icons.chevron_right, color: scheme.onSurface),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: weekdayStyle,
          weekendStyle: weekdayStyle.copyWith(color: scheme.error),
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        calendarBuilders: CalendarBuilders(
          // table_calendar has one weekend style (Sunday, red), so
          // Saturday gets its blue here; null falls back to the default.
          dowBuilder: (context, day) => day.weekday != DateTime.saturday
              ? null
              : Center(
                  child: Text(
                    DateFormat.E("ko_KR").format(day),
                    style: weekdayStyle.copyWith(color: scheme.primary),
                  ),
                ),
          // Every day cell is ours: number on top, schedule titles under.
          prioritizedBuilder: (context, day, _) => ScheduleDayCell(
            day: day,
            labels: schedule.labelsOn(day),
            isToday: isSameDay(day, schedule.today),
            isSelected: isSameDay(day, schedule.selectedDay),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        calendar,

        const Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: ScheduleAddButton(),
        ),
      ],
    );
  }
}
