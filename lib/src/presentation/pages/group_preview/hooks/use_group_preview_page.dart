import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/hooks/hooks.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 공개 모임 미리보기의 상태와 동작. [data]는 미리보기 ViewModel 그대로,
/// [categoryNames]는 카테고리 id를 이름으로 바꾼 것. [busy]는 신청·취소 중.
/// [request]는 가입 신청, [cancel]은 액션시트로 묻고 신청 취소 (결과는 스낵바).
({
  AsyncValue<GroupSearchResult?> data,
  List<String> categoryNames,
  bool busy,
  VoidCallback close,
  VoidCallback request,
  VoidCallback cancel,
  void Function(int groupId) openGroup,
})
useGroupPreviewPage(WidgetRef ref, int groupId) {
  final context = useContext();

  final (:busy, :run) = useRequestRunner();

  final provider = groupPreviewViewModelProvider(groupId);

  final data = ref.watch(provider);

  final viewModel = ref.read(provider.notifier);

  final categories = ref.watch(groupCategoriesProvider).value ?? const [];

  final group = data.value;

  final categoryNames = [
    if (group != null)
      for (final c in categories)
        if (group.categories.contains(c.id)) c.name,
  ];

  Future<void> request() async {
    if (await run(viewModel.request) && context.mounted) {
      showAppSnackBar(
        context,
        "가입을 신청했어요. 그룹장이 수락하면 참여돼요",
        icon: LucideIcons.circleCheck,
      );
    }
  }

  Future<void> cancel() async {
    final ok = await showAppConfirmSheet(
      context,
      title: "가입 신청을 취소할까요?",
      message: "취소한 뒤에도 다시 가입 신청할 수 있어요.",
      action: "신청 취소",
    );

    if (ok && await run(viewModel.cancel) && context.mounted) {
      showAppSnackBar(context, "가입 신청을 취소했어요");
    }
  }

  return (
    data: data,
    categoryNames: categoryNames,
    busy: busy,
    close: () =>
        context.canPop() ? context.pop() : context.go("/group/explore"),
    request: request,
    cancel: cancel,
    openGroup: (groupId) => context.go("/group/$groupId"),
  );
}
