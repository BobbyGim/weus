import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// One schedule of the selected day: a colored bar (공동일정은 민트색), then
/// title over description. 누르면 [onTap] (수정 시트 열기), null이면 누를 수 없다.
class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    super.key,
    required this.title,
    required this.description,
    required this.isShared,
    required this.onTap,
    required this.onDelete,
  });

  final String title;

  final String description;

  final bool isShared;

  final VoidCallback? onTap;

  /// 휴지통 버튼을 누르면. null이면(공동일정) 버튼이 없다.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isShared ? scheme.tertiary : scheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        description,
                        style: text.bodyMedium!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                if (onDelete != null)
                  Center(
                    child: IconButton(
                      onPressed: onDelete,
                      tooltip: "일정 삭제",
                      color: AppColors.gray400,
                      icon: const Icon(LucideIcons.trash2, size: 18),
                    ),
                  ),

                // 공동일정이든 아니든 맨 오른쪽 같은 자리: 공동일정(읽기 전용)은
                // 사람들 아이콘, 내 일정은 수정할 수 있다는 연필.
                Center(
                  child: Icon(
                    isShared ? LucideIcons.users : LucideIcons.pencil,
                    size: 18,
                    color: isShared ? scheme.tertiary : AppColors.gray400,
                    semanticLabel: isShared ? "공동일정" : "수정 가능",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
