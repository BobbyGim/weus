import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";

import "../view_models/view_models.dart";

/// 그룹 홈의 상태와 동작. [data]는 그룹 홈 ViewModel 그대로, [categoryNames]는
/// 그룹 카테고리 id를 이름으로 바꾼 것 (아직 못 불러왔으면 빈 목록).
/// 멤버가 아닌 사람이 링크로 열면 미리보기로 넘긴다 (공개 모임이면 가입 신청,
/// 아니면 없는 모임). [onScroll]은 목록 끝에 가까워지면 다음 글을 불러온다.
({
  AsyncValue<GroupHome> data,
  List<String> categoryNames,
  VoidCallback close,
  VoidCallback write,
  VoidCallback openSettings,
  void Function(int postId) openPost,
  bool Function(ScrollNotification notification) onScroll,
  VoidCallback refresh,
  VoidCallback loadMore,
})
useGroupDetailPage(WidgetRef ref, int groupId) {
  final context = useContext();

  final provider = groupDetailViewModelProvider(groupId);

  final data = ref.watch(provider);

  final viewModel = ref.read(provider.notifier);

  final categories = ref.watch(groupCategoriesProvider).value ?? const [];

  ref.listen(provider, (_, next) {
    if (next case AsyncError(error: GroupFailure())) {
      context.go("/group/explore/$groupId");
    }
  });

  final header = data.value?.header;

  final categoryNames = [
    if (header != null)
      for (final c in categories)
        if (header.categories.contains(c.id)) c.name,
  ];

  // 글을 올리고 돌아오면(true) 새 글이 맨 위에 보이게 다시 불러온다.
  Future<void> write() async {
    final posted = await context.push<bool>("/group/$groupId/post/new");

    if (posted == true) viewModel.refresh();
  }

  // 설정에서 멤버를 내보내거나 그룹을 수정했을 수 있어 돌아오면 다시 불러온다.
  Future<void> openSettings() async {
    await context.push("/group/$groupId/settings");

    if (context.mounted) viewModel.refresh();
  }

  bool onScroll(ScrollNotification n) {
    final failed = data.value?.failed ?? false;

    if (n.metrics.extentAfter < 600 && !failed) viewModel.loadMore();

    return false;
  }

  return (
    data: data,
    categoryNames: categoryNames,
    close: () => context.canPop() ? context.pop() : context.go("/group"),
    write: write,
    openSettings: openSettings,
    openPost: (postId) => context.push("/group/$groupId/post/$postId"),
    onScroll: onScroll,
    refresh: viewModel.refresh,
    loadMore: viewModel.loadMore,
  );
}
