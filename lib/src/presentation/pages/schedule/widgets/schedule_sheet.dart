import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:intl/intl.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "hooks/use_schedule_sheet.dart";
import "schedule_add_button.dart";
import "schedule_tile.dart";

/// Bottom sheet body, 70% of the screen: the day's date, then its schedules, or an
/// icon + note in the middle when the day has none.
class ScheduleSheet extends HookWidget {
  const ScheduleSheet({super.key, required this.day, required this.schedules});

  final DateTime day;

  final List<({String title, String description})> schedules;

  @override
  Widget build(BuildContext context) {
    final sheet = useScheduleSheet();

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // Bouncing "more below" arrow; it stands still when the OS "reduce
    // motion" setting is on.
    final arrow = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(
        LucideIcons.chevronDown,
        size: 22,
        color: scheme.onSurfaceVariant,
      ),
    );

    // The sheet is always 70% of the screen, however few schedules.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: SafeArea(
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
                            LucideIcons.calendarX,
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
                  // inside that when there are more schedules); the Spacer keeps
                  // the bottom half free, so dragging down there closes the
                  // sheet. primary: false = a list that fits doesn't grab the
                  // drag either.
                  if (schedules.isNotEmpty) ...[
                    Flexible(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          NotificationListener(
                            onNotification: sheet.onListNotification,
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

                          // Shown only while more schedules are below.
                          IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: sheet.hasMore ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: MediaQuery.disableAnimationsOf(context)
                                    ? arrow
                                    : arrow
                                          .animate(
                                            onPlay: (c) =>
                                                c.repeat(reverse: true),
                                          )
                                          .moveY(
                                            begin: -3,
                                            end: 3,
                                            duration: 600.ms,
                                            curve: Curves.easeInOut,
                                          ),
                              ),
                            ),
                          ),
                        ],
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
      ),
    );
  }
}
