import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

/// 모임 만들기·수정이 같이 쓰는 입력 칸: 모임 이름, 카테고리(최대 3개), 소개.
/// 길이 제한은 groups 테이블 제약과 같다.
class GroupFormFields extends StatelessWidget {
  const GroupFormFields({
    super.key,
    required this.name,
    required this.description,
    required this.categories,
    required this.selected,
    required this.onToggleCategory,
  });

  final TextEditingController name;

  final TextEditingController description;

  /// 고를 수 있는 카테고리 전부.
  final List<GroupCategory> categories;

  /// 고른 카테고리 id.
  final List<String> selected;

  final ValueChanged<String> onToggleCategory;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // 입력 칸 위의 라벨.
    Widget labeled(String label, Widget field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
        ),

        const SizedBox(height: AppSpacing.sm),

        field,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        labeled(
          "그룹 이름",
          TextField(
            controller: name,
            maxLength: 30,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "예: 주말 러닝 크루",
              counterText: "",
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // 3개를 고르면 나머지 칩은 눌리지 않는다.
        labeled(
          "카테고리 (최대 3개)",
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in categories)
                FilterChip(
                  label: Text(c.name),
                  selected: selected.contains(c.id),
                  showCheckmark: false,
                  onSelected: selected.length < 3 || selected.contains(c.id)
                      ? (_) => onToggleCategory(c.id)
                      : null,
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        labeled(
          "그룹 소개 (선택)",
          TextField(
            controller: description,
            maxLength: 500,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(hintText: "어떤 그룹인지 소개해 주세요"),
          ),
        ),
      ],
    );
  }
}
