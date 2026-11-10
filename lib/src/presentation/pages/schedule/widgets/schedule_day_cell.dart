import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// Labels past the third are not shown in the cell (the day's sheet has all).
const _maxLabels = 3;

/// A schedule as one day's cell shows it. A multi-day schedule is a bar of
/// [span] cells in this week row, and this day is its cell number [index]
/// (0-based); a one-day schedule has index 0 and span 1.
typedef ScheduleLabel = ({String title, bool isMultiDay, int index, int span});

/// One day of the month grid: the day number on top, then up to 3 schedule
/// labels in order. A one-day schedule is a soft chip; a multi-day one is a
/// solid bar that runs edge to edge so it joins up across its days.
class ScheduleDayCell extends StatelessWidget {
  const ScheduleDayCell({
    super.key,
    required this.day,
    required this.labels,
    required this.isToday,
    required this.isSelected,
  });

  final DateTime day;

  /// One per row; null is an empty row (a multi-day bar below keeps its row).
  final List<ScheduleLabel?> labels;

  final bool isToday;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final dayColor = switch (day.weekday) {
      _ when isToday => scheme.primary,
      DateTime.sunday => scheme.error,
      DateTime.saturday => scheme.tertiary,
      _ => scheme.onSurface,
    };

    final labelStyle = text.labelSmall!.copyWith(fontSize: 10);

    Widget label(ScheduleLabel? l) {
      // Empty row: same height as a label, nothing drawn.
      if (l == null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(" ", style: labelStyle),
        );
      }

      if (!l.isMultiDay) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(1, 0, 1, 2),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            l.title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: labelStyle.copyWith(color: scheme.onPrimaryContainer),
          ),
        );
      }

      // The bar is rounded only at its two ends; in between it is flush so
      // the cells join into one bar.
      final opens = l.index == 0;

      final closes = l.index == l.span - 1;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(opens ? 4 : 0),
            right: Radius.circular(closes ? 4 : 0),
          ),
        ),
        // The title is laid out once across the whole bar, centered, and
        // each cell shows only its own slice of it, so the slices line up
        // into one title in the middle of the bar.
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * l.span;

              return OverflowBox(
                fit: OverflowBoxFit.deferToChild,
                minWidth: barWidth,
                maxWidth: barWidth,
                alignment: Alignment(
                  l.span == 1 ? 0 : -1 + 2 * l.index / (l.span - 1),
                  0,
                ),
                child: Text(
                  l.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: labelStyle.copyWith(color: scheme.onPrimary),
                ),
              );
            },
          ),
        ),
      );
    }

    // Fills the cell so every day starts at the top of its row. The scroll
    // view never scrolls: it only clips the labels when a short screen or a
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

            for (final l in labels.take(_maxLabels)) label(l),
          ],
        ),
      ),
    );
  }
}
