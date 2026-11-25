import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";
import "package:weus/src/utils/utils.dart";

import "../view_models/view_models.dart";

/// 모임 만들기 폼. 모임 이름이 공백만 아니고 카테고리를 1~3개 고르면 만들 수
/// 있다 (소개는 선택). [toggleCategory]는 3개를 넘게 고르려 하면 무시한다.
/// 공개 모임으로 시작한다 ([isPublic]이면 모임 찾기에 보인다).
/// [clientId]는 이 화면이 열려 있는 동안 같은 값이라, 두 번 탭하거나 실패 후
/// 다시 보내도 모임은 하나만 생긴다. [options]는 고를 수 있는 카테고리 전체,
/// [submit]은 만들 수 있을 때만 있다 (아니면 null, 버튼이 꺼진다).
/// 만들면 스낵바를 띄우고 모임 탭으로 돌아가고, 실패하면 스낵바만.
({
  TextEditingController name,
  TextEditingController description,
  List<GroupCategory> options,
  List<String> categories,
  ValueChanged<String> toggleCategory,
  bool isPublic,
  ValueChanged<bool> setPublic,
  bool loading,
  VoidCallback? submit,
})
useGroupCreatePage(WidgetRef ref) {
  final context = useContext();

  final name = useTextEditingController();

  final description = useTextEditingController();

  final clientId = useMemoized(newUuid);

  final isPublic = useState(true);

  final categories = useState(const <String>[]);

  final loading = ref.watch(groupCreateViewModelProvider).isLoading;

  final options = ref.watch(groupCategoriesProvider).value ?? const [];

  ref.listen(groupCreateViewModelProvider, (_, next) {
    switch (next) {
      case AsyncData(value: != null):
        showAppSnackBar(context, "그룹을 만들었어요", icon: LucideIcons.circleCheck);

        context.canPop() ? context.pop() : context.go("/group");

      case AsyncError():
        showAppSnackBar(context, "그룹을 만들지 못했어요. 잠시 후 다시 시도해 주세요");

      default:
    }
  });

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

  final filled = name.text.trim().isNotEmpty && categories.value.isNotEmpty;

  void submit() => ref
      .read(groupCreateViewModelProvider.notifier)
      .create(
        name: name.text.trim(),
        description: description.text.trim(),
        categories: categories.value,
        isPublic: isPublic.value,
        clientId: clientId,
      );

  return (
    name: name,
    description: description,
    options: options,
    categories: categories.value,
    toggleCategory: toggleCategory,
    isPublic: isPublic.value,
    setPublic: (value) => isPublic.value = value,
    loading: loading,
    submit: filled && !loading ? submit : null,
  );
}
