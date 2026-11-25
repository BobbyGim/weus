import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 그룹 설정의 한 묶음: 회색 소제목 [title] 아래에 [child] (보통 [Card]).
class GroupSettingsSection extends StatelessWidget {
  const GroupSettingsSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
          ),

          const SizedBox(height: AppSpacing.sm),

          child,
        ],
      ),
    );
  }
}
