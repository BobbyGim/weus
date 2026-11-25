import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 모임 탭의 상태와 동작. [data]는 모임 탭 ViewModel 그대로.
/// [cancel]은 액션시트로 묻고 가입 신청을 취소한다 (결과는 스낵바).
/// [onScroll]은 목록 끝에 가까워지면 다음 그룹을 불러온다.
({
  AsyncValue<({MyGroupsPage mine, List<MyJoinRequest> requests})> data,
  void Function(MyJoinRequest request) cancel,
  bool Function(ScrollNotification notification) onScroll,
  void Function(int groupId) openGroup,
  VoidCallback openExplore,
  VoidCallback openJoin,
  VoidCallback openCreate,
  VoidCallback refresh,
  VoidCallback loadMore,
})
useGroupPage(WidgetRef ref) {
  final context = useContext();

  final data = ref.watch(groupViewModelProvider);

  final viewModel = ref.read(groupViewModelProvider.notifier);

  Future<void> cancel(MyJoinRequest request) async {
    final ok = await showAppConfirmSheet(
      context,
      title: "가입 신청을 취소할까요?",
      message: "${request.groupName}에 낸 신청을 취소해요. 취소한 뒤에도 다시 신청할 수 있어요.",
      action: "신청 취소",
    );

    if (!ok) return;

    try {
      await viewModel.cancelRequest(request.id);

      if (context.mounted) showAppSnackBar(context, "가입 신청을 취소했어요");
    } on GroupFailure catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, "잠시 후 다시 시도해 주세요");
    }
  }

  bool onScroll(ScrollNotification n) {
    final failed = data.value?.mine.failed ?? false;

    if (n.metrics.extentAfter < 600 && !failed) viewModel.loadMore();

    return false;
  }

  return (
    data: data,
    cancel: cancel,
    onScroll: onScroll,
    openGroup: (groupId) => context.go("/group/$groupId"),
    openExplore: () => context.go("/group/explore"),
    openJoin: () => context.go("/group/join"),
    openCreate: () => context.go("/group/new"),
    refresh: viewModel.refresh,
    loadMore: viewModel.loadMore,
  );
}
