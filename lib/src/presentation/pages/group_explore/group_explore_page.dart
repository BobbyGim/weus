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

/// 공개 모임을 이름·카테고리로 찾아 가입 신청한다 (거르기는 DB에서). 이미 참여한 모임은 누르면 상세로 간다.
/// 이름 검색은 키보드의 검색 키를 눌러야 하고, 검색어는 주소 쿼리(`?q=`)로 남는다.
class GroupExplorePage extends HookConsumerWidget {
  const GroupExplorePage({super.key, required this.query});

  /// 주소의 검색어 (`/group/explore?q=러닝`, 없으면 빈 문자열 = 전부).
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = useGroupExplorePage(query);

    final provider = groupExploreViewModelProvider(query, page.category);

    // 검색: 검색어를 주소에 넣어 바꾼다. replace라 검색을 여러 번 해도 뒤로가기는 그 탭으로.
    void search() {
      final q = page.input.text.trim();

      FocusScope.of(context).unfocus();

      context.replace(
        Uri(
          path: "/group/explore",
          queryParameters: q.isEmpty ? null : {"q": q},
        ).toString(),
      );
    }

    final categories = ref.watch(groupCategoriesProvider).value ?? const [];

    final categoryNames = {for (final c in categories) c.id: c.name};

    final results = ref.watch(provider);

    final viewModel = ref.read(provider.notifier);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // 멤버면 상세, 아니면 미리보기를 먼저 불러온 뒤(이 화면에 로딩) 위에 올려서,
    // 미리보기가 로딩 없이 바로 그려진다. 못 불러오면 열지 않고 스낵바만.
    Future<void> open(GroupSearchResult group) async {
      if (group.isMember) return context.go("/group/${group.id}");

      if (await page.run(() => viewModel.loadPreview(group.id)) &&
          context.mounted) {
        // 이 화면 위에 쌓아서(push), 닫으면 검색 결과 그대로 모임 찾기로 돌아온다.
        // go면 홈에서 연 모임 찾기 아래가 모임 탭으로 바뀌어 버린다.
        context.push("/group/explore/${group.id}");
      }
    }

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

    final list = switch (results.value) {
      (groups: [], hasMore: _, loadingMore: _, failed: _) => message(
        query.isEmpty && page.category == null
            ? "참여할 수 있는 그룹이 없어요"
            : "조건에 맞는 그룹이 없어요",
      ),

      (:final groups, :final hasMore, loadingMore: _, :final failed) =>
        RefreshIndicator(
          onRefresh: viewModel.refresh,
          // 끝에서 한 화면쯤 남으면 다음 20개를 미리 불러온다 (불러오는 중이면 무시).
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 600 && !failed) viewModel.loadMore();

              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      categoryNames: [
                        for (final id in groups[i].categories)
                          ?categoryNames[id],
                      ],
                      memberCount: groups[i].memberCount,
                      badge: groups[i].isMember
                          ? "참여 중"
                          : groups[i].isPending
                          ? "신청 중"
                          : null,
                      badgeHighlighted: groups[i].isMember,
                      onTap: () => open(groups[i]),
                    )
                  : SizedBox(
                      height: 96,
                      child: Center(
                        child: failed
                            ? TextButton(
                                onPressed: viewModel.loadMore,
                                child: const Text("더 불러오지 못했어요 · 다시 시도"),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),

                                  const SizedBox(height: AppSpacing.md),

                                  Text(
                                    "그룹을 더 불러오는 중",
                                    style: text.bodyMedium!.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
          ),
        ),

      null when results.hasError => message(
        "그룹을 불러오지 못했어요",
        action: TextButton(
          onPressed: viewModel.refresh,
          child: const Text("다시 시도"),
        ),
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
                onSubmitted: (_) => search(),
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
            if (categories.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final id = i == 0 ? null : categories[i - 1].id;

                    return Center(
                      child: ChoiceChip(
                        label: Text(i == 0 ? "전체" : categories[i - 1].name),
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
