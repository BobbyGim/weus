import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 공개 범위 고르기의 한 칸 (공개 / 비공개). 고르면 테두리와 체크가 ink로 바뀐다.
class GroupVisibilityOption extends StatelessWidget {
  const GroupVisibilityOption({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.pairDescription,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;

  final String title;

  final String description;

  /// 함께 놓인 다른 칸의 설명. 두 칸 높이를 맞추는 데만 쓴다.
  final String pairDescription;

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final descriptionStyle = text.bodySmall!.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: selected
          ? BorderSide(color: scheme.secondary, width: 1.5)
          : BorderSide(color: scheme.outlineVariant),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? scheme.secondary
                        : scheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleSmall),

                      const SizedBox(height: 2),

                      // 짝 칸 설명을 안 보이게 겹쳐 두어, 두 칸이 긴 쪽 높이로 같아진다.
                      Stack(
                        children: [
                          ExcludeSemantics(
                            child: Opacity(
                              opacity: 0,
                              child: Text(
                                pairDescription,
                                style: descriptionStyle,
                              ),
                            ),
                          ),

                          Text(description, style: descriptionStyle),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Icon(
                  selected ? LucideIcons.circleCheck : LucideIcons.circle,
                  size: 22,
                  color: selected ? scheme.secondary : scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
