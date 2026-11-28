import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "widgets/widgets.dart";

/// 공개 범위 → 카테고리 → 이름·소개 순서로 한 단계씩 받아 모임을 만든다.
/// 만든 사람이 owner가 되고, 만들면 모임 탭으로 돌아간다.
class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupCreatePage(ref);

    final scheme = Theme.of(context).colorScheme;

    final last = form.step == groupCreateSteps - 1;

    // 뒤로가기(버튼·안드로이드 뒤로)는 이전 단계로, 첫 단계면 나가기 (iOS 스와이프는 꺼진다).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) form.back();
      },
      child: AppLoadingOverlay(
        loading: form.loading,
        label: "그룹 만드는 중",
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: "뒤로",
              icon: const Icon(LucideIcons.chevronLeft),
              onPressed: form.back,
            ),
            // 어느 단계에서든 바로 나가기.
            actions: [
              IconButton(
                tooltip: "닫기",
                icon: const Icon(LucideIcons.x),
                onPressed: form.close,
              ),

              const SizedBox(width: AppSpacing.xs),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: TweenAnimationBuilder(
                tween: Tween<double>(end: (form.step + 1) / groupCreateSteps),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 3,
                  color: scheme.secondary,
                  backgroundColor: scheme.surfaceContainerHigh,
                  // 값은 숫자(%)만 되어서 단계는 라벨에 넣는다.
                  semanticsLabel:
                      "그룹 만들기 $groupCreateSteps단계 중 ${form.step + 1}단계",
                ),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PageView(
                        controller: form.pages,
                        // 다음 단계는 버튼으로만, 이전 단계는 버튼·가장자리 끌기로.
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          GroupCreateStep(
                            title: "누가 이 그룹을 찾을 수 있나요?",
                            subtitle: "만든 뒤에도 그룹 설정에서 바꿀 수 있어요",
                            child: Column(
                              children: [
                                GroupVisibilityOption(
                                  icon: LucideIcons.globe,
                                  title: "공개 그룹",
                                  description: "누구나 찾고 신청할 수 있어요",
                                  pairDescription: "초대 코드로만 신청할 수 있어요",
                                  selected: form.isPublic,
                                  onTap: () => form.setPublic(true),
                                ),

                                const SizedBox(height: AppSpacing.sm),

                                GroupVisibilityOption(
                                  icon: LucideIcons.lock,
                                  title: "비공개 그룹",
                                  description: "초대 코드로만 신청할 수 있어요",
                                  pairDescription: "누구나 찾고 신청할 수 있어요",
                                  selected: !form.isPublic,
                                  onTap: () => form.setPublic(false),
                                ),
                              ],
                            ),
                          ),

                          GroupCreateStep(
                            title: "어떤 활동을 하는 그룹인가요?",
                            subtitle:
                                "최대 3개까지 고를 수 있어요 (${form.categories.length}/3)",
                            child: GroupCategoryChips(
                              categories: form.options,
                              selected: form.categories,
                              onToggle: form.toggleCategory,
                            ),
                          ),

                          GroupCreateStep(
                            title: "그룹을 소개해 주세요",
                            subtitle: "이름만 정해도 바로 만들 수 있어요",
                            fill: true,
                            child: GroupFormFields(
                              name: form.name,
                              description: form.description,
                              fillDescription: true,
                            ),
                          ),
                        ],
                      ),

                      // iOS: 왼쪽 가장자리에서 끌면 이전 단계로.
                      if (form.edgeSwipe case final swipe?)
                        GroupCreateEdgeSwipe(
                          onUpdate: swipe.update,
                          onEnd: swipe.end,
                          onCancel: swipe.cancel,
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: FilledButton(
                    onPressed: form.next,
                    child: Text(last ? "그룹 만들기" : "다음"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
