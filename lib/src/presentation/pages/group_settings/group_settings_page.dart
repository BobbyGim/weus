import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 그룹 홈의 ⚙에서 여는 그룹 설정: 초대 코드·멤버, 맨 아래 나가기.
/// owner는 그룹 수정·공개 설정·가입 신청 수락/거절·멤버 내보내기도 한다
/// (owner는 혼자일 때만 나갈 수 있고, 나가면 그룹이 삭제된다).
class GroupSettingsPage extends HookConsumerWidget {
  const GroupSettingsPage({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupSettingsPage(ref, groupId);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final data = page.data;

    final value = data.value;

    final Widget body;

    if (value == null) {
      body = Center(
        child: data.hasError
            ? AppRetry(
                message: data.error is GroupFailure
                    ? (data.error! as GroupFailure).message
                    : "그룹을 불러오지 못했어요",
                onRetry: page.refresh,
              )
            : const CircularProgressIndicator(),
      );
    } else {
      final (detail: current, :requests) = value;

      body = ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          GroupSettingsSummary(
            detail: current,
            categoryNames: page.categoryNames,
          ),

          GroupSettingsSection(
            title: "초대 코드",
            child: GroupSettingsInviteCode(
              code: current.inviteCode,
              onCopy: () => page.copyCode(current.inviteCode),
            ),
          ),

          if (current.isOwner) ...[
            GroupSettingsSection(
              title: "공개 설정",
              child: GroupSettingsPublicSwitch(
                isPublic: current.isPublic,
                onChanged: page.setPublic,
              ),
            ),

            GroupSettingsSection(
              title: "가입 신청 ${requests.length}",
              child: Card(
                child: requests.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          "새 가입 신청이 없어요",
                          style: text.bodyMedium!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final request in requests)
                            GroupSettingsRequestTile(
                              request: request,
                              onApprove: () =>
                                  page.decide(request, approve: true),
                              onReject: () =>
                                  page.decide(request, approve: false),
                            ),
                        ],
                      ),
              ),
            ),
          ],

          GroupSettingsSection(
            title: "멤버 ${current.members.length}명",
            child: Card(
              child: Column(
                children: [
                  for (final member in current.members)
                    GroupSettingsMemberTile(
                      member: member,
                      onRemove: current.isOwner && !member.isMe
                          ? () => page.remove(member)
                          : null,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          TextButton(
            onPressed: page.leave,
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(page.deletes ? "그룹 삭제하고 나가기" : "그룹 나가기"),
          ),
        ],
      );
    }

    return AppLoadingOverlay(
      loading: page.busy,
      label: "처리 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: AppBackButton(fallback: "/group/$groupId"),
          title: const Text("그룹 설정"),
          actions: [
            if (data.value?.detail.isOwner ?? false)
              TextButton(onPressed: page.edit, child: const Text("수정")),
          ],
        ),
        body: body,
      ),
    );
  }
}
