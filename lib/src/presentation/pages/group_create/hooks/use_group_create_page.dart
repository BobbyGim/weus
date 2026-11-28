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

/// 모임 만들기 단계 수: 공개 범위 → 카테고리 → 이름·소개.
const groupCreateSteps = 3;

/// 놓았을 때 이전 단계로 넘어가는 끌기 속도 (iOS 뒤로가기 끌기와 비슷하게).
const _flingVelocity = 700.0;

/// 첫 단계에서 이만큼 끌고 놓으면 나가기를 묻는다.
const _closeDistance = 80.0;

/// 첫 단계 끝에서 끌 때 화면이 따라오는 비율 (고무줄처럼 덜 움직인다).
const _rubberBand = 0.3;

/// 모임 만들기 폼. 세 단계를 [pages]로 넘기며 고른다 ([step]은 0부터).
/// 카테고리는 1~3개 ([toggleCategory]는 3개를 넘게 고르려 하면 무시),
/// 이름은 공백만 아니면 된다 (소개는 선택). 공개 모임으로 시작한다.
/// [next]는 지금 단계를 마쳤을 때만 있다 (아니면 null, 버튼이 꺼진다).
/// 마지막 단계의 [next]가 만들기다. [clientId]는 이 화면이 열려 있는 동안
/// 같은 값이라, 두 번 탭하거나 실패 후 다시 보내도 모임은 하나만 생긴다.
/// [back]은 이전 단계로 가고, 첫 단계에서는 [close]와 같다.
/// [close]는 어느 단계에서든 만들던 내용이 사라진다고 먼저 묻고, 닫기로 하면
/// 이전 페이지로 나간다.
/// [edgeSwipe]는 iOS에서만 있다: 왼쪽 가장자리에서 끌면 이전 단계가 손가락을
/// 따라 들어오고, 첫 단계에서 충분히 끌고 놓으면 [close]처럼 묻는다.
/// 안드로이드는 시스템 뒤로가기가 [back]으로 온다.
/// 만들면 스낵바를 띄우고 모임 탭으로, 실패하면 스낵바만.
({
  int step,
  PageController pages,
  TextEditingController name,
  TextEditingController description,
  List<GroupCategory> options,
  List<String> categories,
  ValueChanged<String> toggleCategory,
  bool isPublic,
  ValueChanged<bool> setPublic,
  bool loading,
  VoidCallback? next,
  VoidCallback back,
  VoidCallback close,
  ({
    GestureDragUpdateCallback update,
    GestureDragEndCallback end,
    VoidCallback cancel,
  })?
  edgeSwipe,
})
useGroupCreatePage(WidgetRef ref) {
  final context = useContext();

  final pages = usePageController();

  final step = useState(0);

  // 첫 단계에서 끈 거리 (나가기를 물을지 정한다).
  final pulled = useRef(0.0);

  final name = useTextEditingController();

  final description = useTextEditingController();

  final clientId = useMemoized(newUuid);

  final isPublic = useState(true);

  final categories = useState(const <String>[]);

  final loading = ref.watch(groupCreateViewModelProvider).isLoading;

  final options = ref.watch(groupCategoriesProvider).value ?? const [];

  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  void leave() => context.canPop() ? context.pop() : context.go("/group");

  ref.listen(groupCreateViewModelProvider, (_, next) {
    switch (next) {
      case AsyncData(value: != null):
        showAppSnackBar(context, "그룹을 만들었어요", icon: LucideIcons.circleCheck);

        leave();

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

  final done = switch (step.value) {
    0 => true,
    1 => categories.value.isNotEmpty,
    _ => name.text.trim().isNotEmpty && !loading,
  };

  void submit() => ref
      .read(groupCreateViewModelProvider.notifier)
      .create(
        name: name.text.trim(),
        description: description.text.trim(),
        categories: categories.value,
        isPublic: isPublic.value,
        clientId: clientId,
      );

  void goTo(int index) {
    // 이전 단계로 가면 키보드를 내린다.
    if (index < step.value) FocusManager.instance.primaryFocus?.unfocus();

    step.value = index;

    pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void next() {
    if (step.value == groupCreateSteps - 1) return submit();

    goTo(step.value + 1);
  }

  // 나갈 때는 무엇을 골랐든 항상 묻는다 (어느 단계에서 나가든 같게).
  Future<void> close() async {
    final ok = await showAppConfirmSheet(
      context,
      title: "그룹 만들기를 그만둘까요?",
      message: "지금 나가면 만들던 내용이 사라져요.",
      action: "닫기",
      cancel: "계속 만들기",
    );

    if (ok && context.mounted) leave();
  }

  // 지금 단계로 되돌아온다 (덜 끌고 놓았을 때).
  void settle() => pages.animateToPage(
    step.value,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
  );

  // 손가락을 따라 이전 단계 쪽으로만 움직인다. 첫 단계는 조금만 늘어난다.
  void dragUpdate(DragUpdateDetails d) {
    final width = pages.position.viewportDimension;

    final current = step.value * width;

    if (step.value == 0) {
      pulled.value = (pulled.value + d.delta.dx).clamp(0, double.infinity);

      return pages.jumpTo(-pulled.value * _rubberBand);
    }

    pages.jumpTo((pages.offset - d.delta.dx).clamp(current - width, current));
  }

  void dragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;

    if (step.value == 0) {
      final far = pulled.value > _closeDistance || velocity > _flingVelocity;

      pulled.value = 0;

      settle();

      if (far) close();

      return;
    }

    final width = pages.position.viewportDimension;

    final progress = (step.value * width - pages.offset) / width;

    progress > 0.5 || velocity > _flingVelocity
        ? goTo(step.value - 1)
        : settle();
  }

  void dragCancel() {
    pulled.value = 0;

    settle();
  }

  return (
    step: step.value,
    pages: pages,
    name: name,
    description: description,
    options: options,
    categories: categories.value,
    toggleCategory: toggleCategory,
    isPublic: isPublic.value,
    setPublic: (value) => isPublic.value = value,
    loading: loading,
    next: done ? next : null,
    back: () => step.value > 0 ? goTo(step.value - 1) : close(),
    close: close,
    edgeSwipe: isIOS
        ? (update: dragUpdate, end: dragEnd, cancel: dragCancel)
        : null,
  );
}
