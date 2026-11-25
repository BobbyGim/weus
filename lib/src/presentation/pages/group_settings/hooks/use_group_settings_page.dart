import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/hooks/hooks.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 그룹 설정의 상태와 동작. [data]는 설정 ViewModel 그대로, [categoryNames]는
/// 카테고리 id를 이름으로 바꾼 것. [busy]는 요청 처리 중 ([useRequestRunner]).
/// [deletes]: 혼자 남은 owner라 나가면 그룹이 삭제된다.
/// 나가기·내보내기는 아래에서 올라오는 액션시트로 묻고, 결과는 스낵바로 알린다.
({
  AsyncValue<({GroupDetail detail, List<JoinRequest> requests})> data,
  List<String> categoryNames,
  bool busy,
  bool deletes,
  void Function(String code) copyCode,
  void Function(bool isPublic) setPublic,
  void Function(JoinRequest request, {required bool approve}) decide,
  void Function(GroupMember member) remove,
  void Function() leave,
  void Function() edit,
  void Function() refresh,
})
useGroupSettingsPage(WidgetRef ref, int groupId) {
  final context = useContext();

  final (:busy, :run) = useRequestRunner();

  final provider = groupSettingsViewModelProvider(groupId);

  final data = ref.watch(provider);

  final viewModel = ref.read(provider.notifier);

  final categories = ref.watch(groupCategoriesProvider).value ?? const [];

  final detail = data.value?.detail;

  final categoryNames = [
    if (detail != null)
      for (final c in categories)
        if (detail.categories.contains(c.id)) c.name,
  ];

  // 혼자 남은 owner가 나가면 그룹이 삭제된다.
  final deletes =
      detail != null && detail.isOwner && detail.members.length == 1;

  void copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));

    showAppSnackBar(context, "초대 코드를 복사했어요", icon: LucideIcons.circleCheck);
  }

  Future<void> leave() async {
    if (detail!.isOwner && detail.members.length > 1) {
      showAppSnackBar(context, "다른 멤버가 있으면 그룹장은 나갈 수 없어요");

      return;
    }

    final ok = await showAppConfirmSheet(
      context,
      title: deletes ? "그룹을 삭제할까요?" : "그룹에서 나갈까요?",
      message: deletes
          ? "그룹장이 나가면 그룹이 삭제되고, 글과 댓글도 더 이상 볼 수 없어요."
          : "나간 뒤에도 초대 코드로 다시 가입 신청할 수 있어요.",
      action: deletes ? "삭제하고 나가기" : "나가기",
    );

    if (!ok || !await run(viewModel.leave) || !context.mounted) return;

    showAppSnackBar(context, deletes ? "그룹을 삭제했어요" : "그룹에서 나왔어요");

    context.go("/group");
  }

  // 그룹 수정: 저장하고 돌아오면(true) 바뀐 내용으로 다시 불러온다.
  Future<void> edit() async {
    final saved = await context.push<bool>("/group/$groupId/edit");

    if (saved == true) viewModel.refresh();
  }

  Future<void> remove(GroupMember member) async {
    final ok = await showAppConfirmSheet(
      context,
      title: "${member.name}님을 내보낼까요?",
      message: "내보낸 뒤에도 다시 가입 신청할 수 있고, 받을지는 그룹장이 정해요.",
      action: "내보내기",
    );

    if (!ok ||
        !await run(() => viewModel.removeMember(member.userId)) ||
        !context.mounted) {
      return;
    }

    showAppSnackBar(context, "${member.name}님을 내보냈어요");
  }

  Future<void> decide(JoinRequest request, {required bool approve}) async {
    final done = await run(
      () => approve
          ? viewModel.approve(request.id)
          : viewModel.reject(request.id),
    );

    if (done && context.mounted) {
      showAppSnackBar(
        context,
        approve ? "${request.name}님이 그룹에 들어왔어요" : "가입 신청을 거절했어요",
      );
    }
  }

  return (
    data: data,
    categoryNames: categoryNames,
    busy: busy,
    deletes: deletes,
    copyCode: copyCode,
    setPublic: (isPublic) => run(() => viewModel.setPublic(isPublic)),
    decide: decide,
    remove: remove,
    leave: leave,
    edit: edit,
    refresh: viewModel.refresh,
  );
}
