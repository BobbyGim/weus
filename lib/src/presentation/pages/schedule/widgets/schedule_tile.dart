import "package:material_ui/material_ui.dart";

import "package:weus/src/presentation/theme/theme.dart";

/// One schedule of the selected day: a blue bar, then title over description.
/// 누르면 [onTap] (수정 시트 열기).
class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;

  final String description;

  final VoidCallback onTap;

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
                    color: scheme.primary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
