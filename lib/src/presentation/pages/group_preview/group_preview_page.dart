import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";

/// 모임 찾기에서 누른 공개 모임의 미리보기 (아래에서 올라온다). 이름·카테고리·인원·소개와
/// 맨 아래 가입 신청 버튼. 이미 멤버면 모임으로 가고, 신청 중이면 신청 취소 버튼이 된다.
class GroupPreviewPage extends HookConsumerWidget {
  const GroupPreviewPage({
    super.key,
    required this.groupId,
    required this.scrollController,
  });

  final int groupId;

  /// 시트가 준 컨트롤러 (맨 위에서 아래로 끌면 닫힌다).
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupPreviewPage(ref, groupId);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final data = page.data;

    final group = data.value;

    // 불러오는 중·실패·없는 모임: 위쪽 그라데이션 없이 닫기 버튼만.
    if (group == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: "닫기",
            icon: const Icon(LucideIcons.x),
            onPressed: page.close,
          ),
        ),
        body: Center(
          child: data.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  data.hasError ? "그룹을 불러오지 못했어요" : "찾을 수 없는 그룹이에요",
                  style: text.titleMedium,
                ),
        ),
      );
    }

    return AppLoadingOverlay(
      loading: page.busy,
      label: "처리 중",
      child: GroupHeroScaffold(
        name: group.name,
        subtitle: [
          ...page.categoryNames,
          "멤버 ${group.memberCount}명",
        ].join(" · "),
        onClose: page.close,
        scrollController: scrollController,
        content: [
          Text(
            group.description.isEmpty ? "그룹 소개가 없어요" : group.description,
            style: text.bodyLarge!.copyWith(
              color: group.description.isEmpty ? scheme.onSurfaceVariant : null,
            ),
          ),
        ],
        bottomBar: group.isMember
            ? GroupHeroBottomButton(
                label: "그룹으로 가기",
                onPressed: () => page.openGroup(group.id),
              )
            : group.isPending
            ? GroupHeroBottomButton(
                label: "가입 신청 취소",
                secondary: true,
                onPressed: page.busy ? null : page.cancel,
              )
            : GroupHeroBottomButton(
                label: "가입 신청",
                onPressed: page.busy ? null : page.request,
              ),
      ),
    );
  }
}
