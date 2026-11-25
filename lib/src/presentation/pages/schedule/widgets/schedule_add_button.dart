import "package:flutter_svg/flutter_svg.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "schedule_add_sheet.dart";

/// Lucide pencil의 몸통 윤곽(24 격자). Lucide에는 채워진 아이콘이 없어서 속은
/// 이 모양을 칠하고 그 위에 선 아이콘을 겹친다.
const _pencilBody =
    '<svg viewBox="0 0 24 24"><path d="M21.174 6.812a1 1 0 0 0-3.986-3.987'
    "L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622"
    'l4.353-1.32a2 2 0 0 0 .83-.497z"/></svg>';

/// Floating pencil that opens the schedule registration sheet, on the
/// calendar.
class ScheduleAddButton extends StatelessWidget {
  const ScheduleAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppFab(
      tooltip: "일정 등록",
      onPressed: () => showScheduleAddSheet(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.string(
            _pencilBody,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              scheme.primaryContainer,
              BlendMode.srcIn,
            ),
          ),

          const Icon(LucideIcons.pencil, size: 24),
        ],
      ),
    );
  }
}
