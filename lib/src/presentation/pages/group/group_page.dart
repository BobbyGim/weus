import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "view_models/view_models.dart";
import "widgets/widgets.dart";

/// 승인 대기 중인 내 신청과 내가 속한 모임 (둘 다 없으면 안내).
/// 내 모임은 20개씩, 끝에 가까워지면 다음 20개. 당겨서 새로고침, + 버튼으로 모임 만들기,
/// "모임 찾기"·"코드로 참여"로 가입 신청.
class GroupPage extends ConsumerWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(groupViewModelProvider);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    final viewModel = ref.read(groupViewModelProvider.notifier);

    final categories = ref.watch(groupCategoriesProvider).value ?? const [];

    final categoryNames = {for (final c in categories) c.id: c.name};

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

    // 목록이 비었거나 실패해도 당겨서 새로고침할 수 있게 스크롤 안에 둔다.
    Widget fill(Widget child) => RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
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

    final body = switch (data.value) {
      (
        mine: (groups: [], hasMore: _, loadingMore: _, failed: _),
        requests: [],
      ) =>
        fill(const GroupEmpty()),

      (
        mine: (:final groups, :final hasMore, loadingMore: _, :final failed),
        :final requests,
      ) =>
        RefreshIndicator(
          onRefresh: viewModel.refresh,
          // 끝에서 한 화면쯤 남으면 다음 20개를 미리 불러온다 (불러오는 중이면 무시).
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 600 && !failed) viewModel.loadMore();

              return false;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      onCancel: () => cancel(request),
                    ),

                    const SizedBox(height: AppSpacing.md),
                  ],

                  const SizedBox(height: AppSpacing.md),
                ],

                heading(
                  "내 모임",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.go("/group/explore"),
                        icon: const Icon(LucideIcons.search, size: 18),
                        label: const Text("모임 찾기"),
                      ),

                      TextButton.icon(
                        onPressed: () => context.go("/group/join"),
                        icon: const Icon(LucideIcons.ticket, size: 18),
                        label: const Text("코드로 참여"),
                      ),
                    ],
                  ),
                ),

                if (groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                    ),
                    child: Text(
                      "아직 참여한 모임이 없어요",
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
                    categoryNames: [
                      for (final id in group.categories) ?categoryNames[id],
                    ],
                    memberCount: group.memberCount,
                    onTap: () => context.go("/group/${group.id}"),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],

                // 더 있으면 끝에 로딩(실패하면 다시 시도) 한 칸.
                if (hasMore)
                  SizedBox(
                    height: 96,
                    child: Center(
                      child: failed
                          ? TextButton(
                              onPressed: viewModel.loadMore,
                              child: const Text("더 불러오지 못했어요 · 다시 시도"),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),

      null when data.hasError => fill(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("모임을 불러오지 못했어요", style: text.titleMedium),

            const SizedBox(height: AppSpacing.sm),

            TextButton(
              onPressed: viewModel.refresh,
              child: const Text("다시 시도"),
            ),
          ],
        ),
      ),

      null => const Center(child: CircularProgressIndicator()),
    };

    return Stack(
      children: [
        Positioned.fill(child: body),

        const Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: GroupAddButton(),
        ),
      ],
    );
  }
}
