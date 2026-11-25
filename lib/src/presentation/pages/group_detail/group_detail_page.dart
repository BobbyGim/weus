import "package:flutter/services.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 아래에서 올라오는 그룹 홈: 위는 그룹 이름·멤버 수, 그 아래
/// 게시글 (20개씩, 끝에 가까워지면 다음 20개). 오른쪽 아래 버튼으로 글쓰기,
/// ⚙로 그룹 설정 (초대 코드·멤버·나가기, owner는 관리도).
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
    final page = useGroupDetailPage(ref, groupId);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final value = page.data.value;

    // 불러오는 중·실패: 닫기 버튼만.
    if (value == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: "닫기",
            icon: const Icon(LucideIcons.x),
            onPressed: page.close,
          ),
        ),
        body: Center(
          child: page.data.hasError
              ? AppRetry(message: "그룹을 불러오지 못했어요", onRetry: page.refresh)
              : const CircularProgressIndicator(),
        ),
      );
    }

    final (:header, :posts, :hasMore, loadingMore: _, :failed) = value;

    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 상태 표시줄 글자를 흰색으로 (색 배경 위).
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: page.onScroll,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: GroupDetailHeader(
                  header: header,
                  categoryNames: page.categoryNames,
                  onClose: page.close,
                  onSettings: page.openSettings,
                ),
              ),

              if (posts.isEmpty)
                SliverPadding(
                  padding: padding.copyWith(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "아직 글이 없어요. 첫 글을 남겨 보세요",
                      style: text.bodyMedium!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

              SliverPadding(
                padding: padding,
                sliver: SliverList.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) => GroupPostTile(
                    post: posts[i],
                    onTap: () => page.openPost(posts[i].id),
                  ),
                ),
              ),

              // 더 있으면 끝에 로딩(실패하면 다시 시도) 한 칸.
              if (hasMore)
                SliverToBoxAdapter(
                  child: AppLoadMore(failed: failed, onRetry: page.loadMore),
                ),

              // 마지막 글이 글쓰기 버튼에 가리지 않게.
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      AppSpacing.lg +
                      56 +
                      AppSpacing.lg +
                      MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AppFab(
          icon: LucideIcons.pencil,
          tooltip: "글쓰기",
          onPressed: page.write,
        ),
      ),
    );
  }
}
