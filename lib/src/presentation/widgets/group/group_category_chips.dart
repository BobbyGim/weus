import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 모임 카테고리 칩 (최대 3개). 3개를 고르면 나머지 칩은 눌리지 않는다.
class GroupCategoryChips extends StatelessWidget {
  const GroupCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  /// 고를 수 있는 카테고리 전부.
  final List<GroupCategory> categories;

  /// 고른 카테고리 id.
  final List<String> selected;

  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final c in categories)
          FilterChip(
            label: Text(c.name),
            selected: selected.contains(c.id),
            showCheckmark: false,
            onSelected: selected.length < 3 || selected.contains(c.id)
                ? (_) => onToggle(c.id)
                : null,
          ),
      ],
    );
  }
}
