import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/hooks/hooks.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../../view_models/view_models.dart";

/// 모임 수정 폼. 지금 값([detail])으로 채워 시작한다. 이름이 공백만 아니고 카테고리가
/// 1~3개이고 하나라도 바뀌었으면 [canSave]. [busy]는 저장 중 ([useRequestRunner]).
/// [options]는 고를 수 있는 카테고리 전체, [categories]는 고른 id.
/// [save]는 저장하고 true를 돌려주며 닫는다 (상세가 다시 불러온다).
({
  TextEditingController name,
  TextEditingController description,
  List<GroupCategory> options,
  List<String> categories,
  ValueChanged<String> toggleCategory,
  bool canSave,
  bool busy,
  VoidCallback save,
})
useGroupEditForm(WidgetRef ref, GroupDetail detail) {
  final context = useContext();

  final options = ref.watch(groupCategoriesProvider).value ?? const [];

  final name = useTextEditingController(text: detail.name);

  final description = useTextEditingController(text: detail.description);

  final categories = useState(detail.categories);

  final (:busy, :run) = useRequestRunner();

  // 입력할 때마다 다시 그려서 저장 버튼이 입력을 따라간다.
  useListenable(Listenable.merge([name, description]));

  void toggleCategory(String id) {
    final current = categories.value;

    if (current.contains(id)) {
      categories.value = [...current]..remove(id);
    } else if (current.length < 3) {
      categories.value = [...current, id];
    }
  }

  Future<void> save() async {
    final saved = await run(
      () => ref
          .read(groupEditViewModelProvider(detail.id).notifier)
          .save(
            name: name.text.trim(),
            description: description.text.trim(),
            categories: categories.value,
          ),
    );

    if (!saved || !context.mounted) return;

    showAppSnackBar(context, "그룹을 수정했어요", icon: LucideIcons.circleCheck);

    context.pop(true);
  }

  final changed =
      name.text.trim() != detail.name ||
      description.text.trim() != detail.description ||
      !_sameItems(categories.value, detail.categories);

  return (
    name: name,
    description: description,
    options: options,
    categories: categories.value,
    toggleCategory: toggleCategory,
    canSave:
        name.text.trim().isNotEmpty &&
        categories.value.isNotEmpty &&
        changed &&
        !busy,
    busy: busy,
    save: save,
  );
}

bool _sameItems(List<String> a, List<String> b) =>
    a.length == b.length && a.toSet().containsAll(b);
