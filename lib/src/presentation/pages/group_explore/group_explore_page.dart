import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";

/// 공개 모임을 이름·카테고리로 찾아 가입 신청한다 (거르기는 DB에서). 이미 참여한 모임은 누르면 상세로 간다.
/// 이름 검색은 키보드의 검색 키를 눌러야 하고, 검색어는 주소 쿼리(`?q=`)로 남는다.
class GroupExplorePage extends HookConsumerWidget {
  const GroupExplorePage({super.key, required this.query});

  /// 주소의 검색어 (`/group/explore?q=러닝`, 없으면 빈 문자열 = 전부).
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupExplorePage(ref, query);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    Widget message(String label, {Widget? action}) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: text.bodyLarge!.copyWith(color: scheme.onSurfaceVariant),
            ),

            ?action,
          ],
        ),
      ),
    );

    final list = switch (page.results.value) {
      (groups: [], hasMore: _, loadingMore: _, failed: _) => message(
        query.isEmpty && page.category == null
            ? "참여할 수 있는 그룹이 없어요"
            : "조건에 맞는 그룹이 없어요",
      ),

      (:final groups, :final hasMore, loadingMore: _, :final failed) =>
        NotificationListener<ScrollNotification>(
          onNotification: page.onScroll,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            // 더 있으면 끝에 로딩(실패하면 다시 시도) 한 칸.
            itemCount: groups.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) => i < groups.length
                ? GroupCard(
                    name: groups[i].name,
                    description: groups[i].description,
                    memberCount: groups[i].memberCount,
                    badge: groups[i].isMember
                        ? "참여 중"
                        : groups[i].isPending
                        ? "신청 중"
                        : null,
                    badgeHighlighted: groups[i].isMember,
                    onTap: () => page.open(groups[i]),
                  )
                : AppLoadMore(
                    failed: failed,
                    onRetry: page.loadMore,
                    label: "그룹을 더 불러오는 중",
                  ),
          ),
        ),

      null when page.results.hasError => message(
        "그룹을 불러오지 못했어요",
        action: TextButton(onPressed: page.refresh, child: const Text("다시 시도")),
      ),

      null => const Center(child: CircularProgressIndicator()),
    };

    return AppLoadingOverlay(
      loading: page.busy,
      label: "그룹 불러오는 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/group"),
          title: const Text("그룹 찾기"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              // 키보드의 검색 키를 눌러야 검색된다 (치는 동안은 검색하지 않음).
              child: TextField(
                controller: page.input,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => page.search(),
                decoration: const InputDecoration(
                  hintText: "그룹 이름으로 검색",
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 20,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),

            // 카테고리 칩: 하나만 고르고, 다시 누르거나 "전체"면 해제.
            if (page.categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: page.categories.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final id = i == 0 ? null : page.categories[i - 1].id;

                    return Center(
                      child: ChoiceChip(
                        label: Text(
                          i == 0 ? "전체" : page.categories[i - 1].name,
                        ),
                        selected: page.category == id,
                        showCheckmark: false,
                        onSelected: (_) => page.selectCategory(
                          page.category == id ? null : id,
                        ),
                      ),
                    );
                  },
                ),
              ),

            Expanded(child: list),
          ],
        ),
      ),
    );
  }
}
