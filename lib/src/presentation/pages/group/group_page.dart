import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 승인 대기 중인 내 신청과 내가 속한 모임 (둘 다 없으면 안내).
/// 내 모임은 20개씩, 끝에 가까워지면 다음 20개. + 버튼으로 모임 만들기,
/// "내 그룹" 옆 아이콘(돋보기·티켓)으로 그룹 찾기·코드로 참여.
class GroupPage extends HookConsumerWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupPage(ref);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // 빈 화면·실패 안내를 화면 가운데에 (키보드·작은 화면이면 스크롤).
    Widget fill(Widget child) => CustomScrollView(
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );

    Widget heading(String label, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),

          ?trailing,
        ],
      ),
    );

    final body = switch (page.data.value) {
      (
        mine: (groups: [], hasMore: _, loadingMore: _, failed: _),
        requests: [],
      ) =>
        fill(const GroupEmpty()),

      (
        mine: (:final groups, :final hasMore, loadingMore: _, :final failed),
        :final requests,
      ) =>
        NotificationListener<ScrollNotification>(
          onNotification: page.onScroll,
          child: ListView(
            // 마지막 카드가 + 버튼에 가리지 않게 아래를 띄운다.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg + 56 + AppSpacing.lg,
            ),
            children: [
              if (requests.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),

                heading("승인 대기 중"),

                const SizedBox(height: AppSpacing.sm),

                for (final request in requests) ...[
                  GroupRequestCard(
                    request: request,
                    onCancel: () => page.cancel(request),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],

                const SizedBox(height: AppSpacing.md),
              ],

              heading(
                "내 그룹",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: page.openExplore,
                      tooltip: "그룹 찾기",
                      icon: const Icon(LucideIcons.search, size: 22),
                    ),

                    IconButton(
                      onPressed: page.openJoin,
                      tooltip: "코드로 참여",
                      icon: const Icon(LucideIcons.ticket, size: 22),
                    ),
                  ],
                ),
              ),

              if (groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Text(
                    "아직 참여한 그룹이 없어요",
                    textAlign: TextAlign.center,
                    style: text.bodyMedium!.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),

              for (final group in groups) ...[
                GroupCard(
                  name: group.name,
                  description: group.description,
                  memberCount: group.memberCount,
                  onTap: () => page.openGroup(group.id),
                ),

                const SizedBox(height: AppSpacing.md),
              ],

              // 더 있으면 끝에 로딩(실패하면 다시 시도) 한 칸.
              if (hasMore) AppLoadMore(failed: failed, onRetry: page.loadMore),
            ],
          ),
        ),

      null when page.data.hasError => fill(
        Center(
          child: AppRetry(message: "그룹을 불러오지 못했어요", onRetry: page.refresh),
        ),
      ),

      null => const Center(child: CircularProgressIndicator()),
    };

    return TabScrollReset(
      path: "/group",
      child: Stack(
        children: [
          Positioned.fill(child: body),

          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: AppFab(
              icon: LucideIcons.plus,
              tooltip: "그룹 만들기",
              onPressed: page.openCreate,
            ),
          ),
        ],
      ),
    );
  }
}
