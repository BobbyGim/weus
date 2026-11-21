import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/hooks/hooks.dart";

/// 모임 찾기. [input]은 주소의 검색어([query])로 시작하는 검색창 (치는 동안은 검색하지
/// 않고, 키보드의 검색 키를 눌러야 주소가 바뀌며 검색된다). [category]는 고른 카테고리 id, 전체면
/// null. [busy]·[run]은 [useRequestRunner] (카드를 눌러 미리보기를 불러오는 동안).
({
  TextEditingController input,
  String? category,
  ValueChanged<String?> selectCategory,
  bool busy,
  Future<bool> Function(Future<void> Function() action) run,
})
useGroupExplorePage(String query) {
  final input = useTextEditingController(text: query);

  final category = useState<String?>(null);

  final (:busy, :run) = useRequestRunner();

  return (
    input: input,
    category: category.value,
    selectCategory: (id) => category.value = id,
    busy: busy,
    run: run,
  );
}
