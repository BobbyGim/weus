import "package:flutter/material.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// Titles past the third are not shown in the cell (the day's sheet has all).
const _maxTitles = 3;

/// One day of the month grid: the day number on top, then up to 3 schedule
/// titles in order.
class ScheduleDayCell extends StatelessWidget {
  const ScheduleDayCell({
    super.key,
    required this.day,
    required this.titles,
    required this.isToday,
    required this.isSelected,
  });

  final DateTime day;

  final List<String> titles;

  final bool isToday;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final dayColor = switch (day.weekday) {
      _ when isToday => scheme.primary,
      DateTime.sunday => scheme.error,
      DateTime.saturday => scheme.primary,
      _ => scheme.onSurface,
    };

    // Fills the cell so every day starts at the top of its row. The scroll
    // view never scrolls: it only clips the titles when a short screen or a
    // large text size leaves the row too little height.
    return Container(
      width: double.infinity,
      height: double.infinity,
      // Selected day: the whole cell turns gray.
      decoration: BoxDecoration(
        color: isSelected ? scheme.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          children: [
            // Today keeps a blue ring around its number.
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: scheme.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                "${day.day}",
                style: text.bodyMedium!.copyWith(
                  color: dayColor,
                  fontWeight: isToday ? FontWeight.w700 : null,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),

            const SizedBox(height: 4),

            for (final title in titles.take(_maxTitles))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(1, 0, 1, 2),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: text.labelSmall!.copyWith(
                    fontSize: 10,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
