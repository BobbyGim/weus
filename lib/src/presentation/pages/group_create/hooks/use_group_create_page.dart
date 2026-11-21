import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/utils/utils.dart";

/// 모임 만들기 폼. 모임 이름이 공백만 아니고 카테고리를 1~3개 고르면 만들 수
/// 있다 (소개는 선택). [toggleCategory]는 3개를 넘게 고르려 하면 무시한다.
/// 공개 모임으로 시작한다 ([isPublic]이면 모임 찾기에 보인다).
/// [clientId]는 이 화면이 열려 있는 동안 같은 값이라, 두 번 탭하거나 실패 후
/// 다시 보내도 모임은 하나만 생긴다.
({
  TextEditingController name,
  TextEditingController description,
  String clientId,
  List<String> categories,
  ValueChanged<String> toggleCategory,
  bool isPublic,
  ValueChanged<bool> setPublic,
  bool filled,
})
useGroupCreatePage() {
  final name = useTextEditingController();

  final description = useTextEditingController();

  final clientId = useMemoized(newUuid);

  final isPublic = useState(true);

  final categories = useState(const <String>[]);

  void toggleCategory(String id) {
    final current = categories.value;

    if (current.contains(id)) {
      categories.value = [...current]..remove(id);
    } else if (current.length < 3) {
      categories.value = [...current, id];
    }
  }

  // 입력할 때마다 다시 그려서 버튼이 입력을 따라간다.
  useListenable(name);

  return (
    name: name,
    description: description,
    clientId: clientId,
    categories: categories.value,
    toggleCategory: toggleCategory,
    isPublic: isPublic.value,
    setPublic: (value) => isPublic.value = value,
    filled: name.text.trim().isNotEmpty && categories.value.isNotEmpty,
  );
}
