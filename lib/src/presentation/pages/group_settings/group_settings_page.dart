import "package:cupertino_ui/cupertino_ui.dart"
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "view_models/view_models.dart";
import "widgets/widgets.dart";

/// 아래에서 올라오는 그룹 상세: 위는 모임 이미지와 제목, 아래 시트에 소개·
/// 초대 코드·멤버. owner는 가입 신청을 수락·거절하고 멤버를 내보낸다.
/// 메뉴에서 모임 나가기 (owner는 혼자일 때만, 나가면 모임이 삭제된다), owner는 모임 수정도.
/// 링크(`/group/<id>`)로 열 수 있고, 멤버가 아니면 미리보기로 넘긴다.
class GroupDetailPage extends HookConsumerWidget {
  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.scrollController,
  });

  final int groupId;

  /// 시트가 준 컨트롤러 (맨 위에서 아래로 끌면 닫힌다).
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupDetailPage();

    final provider = groupDetailViewModelProvider(groupId);

    final data = ref.watch(provider);

    final viewModel = ref.read(provider.notifier);

    final categories = ref.watch(groupCategoriesProvider).value ?? const [];

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final detail = data.value?.detail;

    // 멤버가 아닌 사람이 링크로 열면 미리보기로 (공개 모임이면 가입 신청, 아니면 없는 모임).
    ref.listen(provider, (_, next) {
      if (next case AsyncError(error: GroupFailure())) {
        context.go("/group/explore/$groupId");
      }
    });

    // 혼자 남은 owner가 나가면 모임이 삭제된다.
    final deletes =
        detail != null && detail.isOwner && detail.members.length == 1;

    // 일정 삭제처럼 아래에서 올라오는 액션시트로 묻는다. [action]을 누르면 true.
    Future<bool> confirm({
      required String title,
      required String message,
      required String action,
    }) => showAppConfirmSheet(
      context,
      title: title,
      message: message,
      action: action,
    );

    Future<void> leave() async {
      if (detail!.isOwner && detail.members.length > 1) {
        showAppSnackBar(context, "다른 멤버가 있으면 그룹장은 나갈 수 없어요");

        return;
      }

      final ok = await confirm(
        title: deletes ? "그룹을 삭제할까요?" : "그룹에서 나갈까요?",
        message: deletes
            ? "그룹장이 나가면 그룹이 삭제되고, 글과 댓글도 더 이상 볼 수 없어요."
            : "나간 뒤에도 초대 코드로 다시 가입 신청할 수 있어요.",
        action: deletes ? "삭제하고 나가기" : "나가기",
      );

      if (!ok || !await page.run(viewModel.leave) || !context.mounted) return;

      showAppSnackBar(context, deletes ? "그룹을 삭제했어요" : "그룹에서 나왔어요");

      context.go("/group");
    }

    // 모임 수정: 저장하고 돌아오면(true) 바뀐 내용으로 다시 불러온다.
    Future<void> edit() async {
      final saved = await context.push<bool>("/group/$groupId/edit");

      if (saved == true) viewModel.refresh();
    }

    // ⋮: 모임장이면 수정·나가기를 고르는 시트, 멤버는 바로 나가기 확인.
    Future<void> openMenu() async {
      if (!detail!.isOwner) return leave();

      final choice = await showCupertinoModalPopup<String>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop("edit"),
              child: const Text("수정"),
            ),

            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop("leave"),
              child: Text(deletes ? "그룹 삭제하고 나가기" : "나가기"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("닫기"),
          ),
        ),
      );

      if (!context.mounted) return;

      switch (choice) {
        case "edit":
          await edit();

        case "leave":
          await leave();
      }
    }

    Future<void> remove(GroupMember member) async {
      final ok = await confirm(
        title: "${member.name}님을 내보낼까요?",
        message: "내보낸 뒤에도 다시 가입 신청할 수 있고, 받을지는 그룹장이 정해요.",
        action: "내보내기",
      );

      if (!ok ||
          !await page.run(() => viewModel.removeMember(member.userId)) ||
          !context.mounted) {
        return;
      }

      showAppSnackBar(context, "${member.name}님을 내보냈어요");
    }

    Future<void> decide(JoinRequest request, {required bool approve}) async {
      final done = await page.run(
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

    Widget heading(String label) => Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
      ),
    );

    Widget muted(String message) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        message,
        style: text.bodyMedium!.copyWith(color: scheme.onSurfaceVariant),
      ),
    );

    void close() => context.canPop() ? context.pop() : context.go("/group");

    // 모임장 표시 같은 작은 테두리 배지.
    Widget pill(IconData icon, String label) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),

          const SizedBox(width: AppSpacing.xs),

          Text(label, style: text.labelMedium),
        ],
      ),
    );

    final value = data.value;

    // 불러오는 중·실패: 위쪽 그라데이션 없이 닫기 버튼만.
    if (value == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: "닫기",
            icon: const Icon(LucideIcons.x),
            onPressed: close,
          ),
        ),
        body: Center(
          child: data.hasError
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.error is GroupFailure
                          ? (data.error! as GroupFailure).message
                          : "그룹을 불러오지 못했어요",
                      style: text.titleMedium,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextButton(
                      onPressed: viewModel.refresh,
                      child: const Text("다시 시도"),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final (detail: current, :requests) = value;

    final categoryNames = [
      for (final c in categories)
        if (current.categories.contains(c.id)) c.name,
    ];

    return AppLoadingOverlay(
      loading: page.busy,
      label: "처리 중",
      child: GroupHeroScaffold(
        name: current.name,
        subtitle: [
          ...categoryNames,
          "멤버 ${current.members.length}명",
        ].join(" · "),
        onClose: close,
        scrollController: scrollController,
        action: GroupHeroButton(
          icon: LucideIcons.ellipsisVertical,
          tooltip: "메뉴",
          onPressed: openMenu,
        ),
        content: [
          if (current.isOwner) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: pill(LucideIcons.crown, "내가 그룹장"),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],

          Text(
            current.description.isEmpty ? "그룹 소개가 없어요" : current.description,
            style: text.bodyLarge!.copyWith(
              color: current.description.isEmpty
                  ? scheme.onSurfaceVariant
                  : null,
            ),
          ),

          heading("초대 코드"),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.sm,
              ),
              title: Text(
                current.inviteCode,
                style: text.titleLarge!.copyWith(letterSpacing: 2),
              ),
              subtitle: Text(
                "이 코드로 가입 신청할 수 있어요",
                style: text.bodyMedium!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                tooltip: "초대 코드 복사",
                onPressed: () => page.copyCode(current.inviteCode),
                icon: const Icon(LucideIcons.copy, size: 20),
              ),
            ),
          ),

          if (current.isOwner) ...[
            heading("공개 설정"),

            Card(
              child: SwitchListTile(
                value: current.isPublic,
                onChanged: (value) =>
                    page.run(() => viewModel.setPublic(value)),
                title: Text("공개 그룹", style: text.titleMedium),
                subtitle: Text(
                  current.isPublic
                      ? "그룹 찾기에서 누구나 찾고 가입 신청할 수 있어요"
                      : "초대 코드를 받은 사람만 가입 신청할 수 있어요",
                  style: text.bodyMedium!.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            heading("가입 신청 ${requests.length}"),

            Card(
              child: requests.isEmpty
                  ? muted("새 가입 신청이 없어요")
                  : Column(
                      children: [
                        for (final request in requests)
                          GroupDetailRequestTile(
                            request: request,
                            onApprove: () => decide(request, approve: true),
                            onReject: () => decide(request, approve: false),
                          ),
                      ],
                    ),
            ),
          ],

          heading("멤버 ${current.members.length}명"),

          Card(
            child: Column(
              children: [
                for (final member in current.members)
                  GroupDetailMemberTile(
                    member: member,
                    onRemove: current.isOwner && !member.isMe
                        ? () => remove(member)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
