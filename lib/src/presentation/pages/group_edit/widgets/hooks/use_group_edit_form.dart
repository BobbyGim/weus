import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/hooks/hooks.dart";

/// 모임 수정 폼. 지금 값([detail])으로 채워 시작한다. 이름이 공백만 아니고 카테고리가
/// 1~3개이고 하나라도 바뀌었으면 [canSave]. [busy]·[run]은 [useRequestRunner].
({
  TextEditingController name,
  TextEditingController description,
  List<String> categories,
  ValueChanged<String> toggleCategory,
  bool canSave,
  bool busy,
  Future<bool> Function(Future<void> Function() action) run,
})
useGroupEditForm(GroupDetail detail) {
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

  final changed =
      name.text.trim() != detail.name ||
      description.text.trim() != detail.description ||
      !_sameItems(categories.value, detail.categories);

  return (
    name: name,
    description: description,
    categories: categories.value,
    toggleCategory: toggleCategory,
    canSave:
        name.text.trim().isNotEmpty &&
        categories.value.isNotEmpty &&
        changed &&
        !busy,
    busy: busy,
    run: run,
  );
}

bool _sameItems(List<String> a, List<String> b) =>
    a.length == b.length && a.toSet().containsAll(b);
