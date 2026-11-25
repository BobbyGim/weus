import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 그룹 설정 맨 위: 그룹 이름, 그 아래 "내가 그룹장 · 카테고리 · 공개/비공개".
class GroupSettingsSummary extends StatelessWidget {
  const GroupSettingsSummary({
    super.key,
    required this.detail,
    required this.categoryNames,
  });

  final GroupDetail detail;

  final List<String> categoryNames;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(detail.name, style: text.headlineSmall),

        const SizedBox(height: AppSpacing.xs),

        Text(
          [
            if (detail.isOwner) "내가 그룹장",
            ...categoryNames,
            detail.isPublic ? "공개" : "비공개",
          ].join(" · "),
          style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
