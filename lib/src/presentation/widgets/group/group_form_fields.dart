import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";

import "group_category_chips.dart";

/// 모임 만들기·수정이 같이 쓰는 입력 칸: 모임 이름, 카테고리(최대 3개), 소개.
/// [onToggleCategory]가 없으면 카테고리 칸은 빠진다 (만들기는 따로 고른다).
/// [fillDescription]이면 소개 칸이 남은 높이를 다 차지한다 (높이가 정해진 곳에서만).
/// 길이 제한은 groups 테이블 제약과 같다.
class GroupFormFields extends StatelessWidget {
  const GroupFormFields({
    super.key,
    required this.name,
    required this.description,
    this.categories = const [],
    this.selected = const [],
    this.onToggleCategory,
    this.fillDescription = false,
  });

  final TextEditingController name;

  final TextEditingController description;

  final bool fillDescription;

  /// 고를 수 있는 카테고리 전부.
  final List<GroupCategory> categories;

  /// 고른 카테고리 id.
  final List<String> selected;

  final ValueChanged<String>? onToggleCategory;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final labelStyle = text.titleSmall!.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final countStyle = text.labelMedium!.copyWith(color: AppColors.gray400);

    // 글자 수 (이모지 같은 글자도 한 글자로).
    Widget length(TextEditingController controller, int max) =>
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) =>
              Text("${value.text.characters.length}/$max", style: countStyle),
        );

    // 입력 칸 위의 라벨, 오른쪽에 개수. [expand]면 칸이 남은 높이를 채운다.
    Widget labeled(
      String label,
      Widget count,
      Widget field, {
      bool expand = false,
    }) => Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: labelStyle)),

            count,
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        expand ? Expanded(child: field) : field,
      ],
    );

    const aboutDecoration = InputDecoration(
      hintText: "무엇을 하는 그룹인지, 얼마나 자주 모이는지 적어 주세요",
      counterText: "",
    );

    // 채울 때는 남은 높이만큼 늘고 (최소 3줄 정도), 아니면 4~8줄.
    final about = labeled(
      "그룹 소개 (선택)",
      length(description, 500),
      expand: fillDescription,
      fillDescription
          ? ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: TextField(
                controller: description,
                maxLength: 500,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: aboutDecoration,
              ),
            )
          : TextField(
              controller: description,
              maxLength: 500,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              decoration: aboutDecoration,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        labeled(
          "그룹 이름",
          length(name, 30),
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

        if (onToggleCategory case final onToggle?) ...[
          labeled(
            "카테고리 (최대 3개 선택)",
            Text("${selected.length}/3", style: countStyle),
            GroupCategoryChips(
              categories: categories,
              selected: selected,
              onToggle: onToggle,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],

        fillDescription ? Expanded(child: about) : about,
      ],
    );
  }
}
