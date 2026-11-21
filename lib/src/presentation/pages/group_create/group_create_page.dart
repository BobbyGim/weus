import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "view_models/view_models.dart";

/// 모임 이름·소개를 받아 모임을 만든다. 만든 사람이 owner가 되고, 만들면 모임 탭으로 돌아간다.
class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupCreatePage();

    final loading = ref.watch(groupCreateViewModelProvider).isLoading;

    final categories = ref.watch(groupCategoriesProvider).value ?? const [];

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    ref.listen(groupCreateViewModelProvider, (_, next) {
      switch (next) {
        case AsyncData(value: != null):
          showAppSnackBar(context, "그룹을 만들었어요", icon: LucideIcons.circleCheck);

          context.canPop() ? context.pop() : context.go("/group");

        case AsyncError():
          showAppSnackBar(context, "그룹을 만들지 못했어요. 잠시 후 다시 시도해 주세요");

        default:
      }
    });

    void submit() => ref
        .read(groupCreateViewModelProvider.notifier)
        .create(
          name: form.name.text.trim(),
          description: form.description.text.trim(),
          categories: form.categories,
          isPublic: form.isPublic,
          clientId: form.clientId,
        );

    final canSubmit = form.filled && !loading;

    // 칸은 위에, 만들기 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: loading,
      label: "그룹 만드는 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/group"),
          title: const Text("그룹 만들기"),
        ),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            // 화면에 다 들어가면 스크롤·바운스 없음. 키보드에 가려질 때만 스크롤된다.
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GroupFormFields(
                        name: form.name,
                        description: form.description,
                        categories: categories,
                        selected: form.categories,
                        onToggleCategory: form.toggleCategory,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: form.isPublic,
                        onChanged: form.setPublic,
                        title: Text("공개 그룹", style: text.titleMedium),
                        subtitle: Text(
                          form.isPublic
                              ? "그룹 찾기에서 누구나 찾고 가입 신청할 수 있어요"
                              : "초대 코드를 받은 사람만 가입 신청할 수 있어요",
                          style: text.bodyMedium!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const Spacer(),

                      const SizedBox(height: AppSpacing.xxxl),

                      FilledButton(
                        onPressed: canSubmit ? submit : null,
                        child: const Text("그룹 만들기"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
