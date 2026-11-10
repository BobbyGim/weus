import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "package:weus/src/presentation/theme/theme.dart";

import "schedule_add_button.dart";
import "schedule_tile.dart";

/// Full-height bottom sheet body: the day's date, then its schedules, or an
/// icon + note in the middle when the day has none.
class ScheduleSheet extends StatelessWidget {
  const ScheduleSheet({super.key, required this.day, required this.schedules});

  final DateTime day;

  final List<({String title, String description})> schedules;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat("M월 d일 EEEE", "ko_KR").format(day),
                      style: text.titleMedium,
                    ),

                    const Spacer(),

                    if (schedules.isNotEmpty)
                      Text(
                        "${schedules.length}개",
                        style: text.labelMedium!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                if (schedules.isEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy_outlined,
                          size: 48,
                          color: AppColors.gray300,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          "일정이 없어요",
                          style: text.bodyLarge!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Text(
                          "일정을 등록해보세요",
                          style: text.bodySmall!.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),

                // The list gets at most the top half of the sheet (it scrolls
                // inside that when there are more schedules); the Spacer keeps the
                // bottom half free, so dragging down there closes the sheet.
                // primary: false = a list that fits doesn't grab the drag either.
                if (schedules.isNotEmpty) ...[
                  Flexible(
                    // TEMP: red box shows where the ListView is. Remove.
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: ListView(
                        primary: false,
                        shrinkWrap: true,
                        children: [
                          for (final s in schedules)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: ScheduleTile(
                                title: s.title,
                                description: s.description,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ],
            ),

            const Positioned(
              right: 0,
              bottom: AppSpacing.lg,
              child: ScheduleAddButton(),
            ),
          ],
        ),
      ),
    );
  }
}
