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
          showAppSnackBar(context, "모임을 만들었어요", icon: LucideIcons.circleCheck);

          context.canPop() ? context.pop() : context.go("/group");

        case AsyncError():
          showAppSnackBar(context, "모임을 만들지 못했어요. 잠시 후 다시 시도해 주세요");

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

    // 입력 칸 위의 라벨.
    Widget labeled(String label, Widget field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: text.titleSmall!.copyWith(color: scheme.onSurfaceVariant),
        ),

        const SizedBox(height: AppSpacing.sm),

        field,
      ],
    );

    // 칸은 위에, 만들기 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: loading,
      label: "모임 만드는 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/group"),
          title: const Text("모임 만들기"),
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
                      labeled(
                        "모임 이름",
                        TextField(
                          controller: form.name,
                          // groups.name 길이 제한과 같다.
                          maxLength: 30,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: "예: 주말 러닝 크루",
                            counterText: "",
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // 3개를 고르면 나머지 칩은 눌리지 않는다.
                      labeled(
                        "카테고리 (최대 3개)",
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final c in categories)
                              FilterChip(
                                label: Text(c.name),
                                selected: form.categories.contains(c.id),
                                showCheckmark: false,
                                onSelected:
                                    form.categories.length < 3 ||
                                        form.categories.contains(c.id)
                                    ? (_) => form.toggleCategory(c.id)
                                    : null,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      labeled(
                        "모임 소개 (선택)",
                        TextField(
                          controller: form.description,
                          // groups.description 길이 제한과 같다.
                          maxLength: 500,
                          minLines: 4,
                          maxLines: 8,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: "어떤 모임인지 소개해 주세요",
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: form.isPublic,
                        onChanged: form.setPublic,
                        title: Text("공개 모임", style: text.titleMedium),
                        subtitle: Text(
                          form.isPublic
                              ? "모임 찾기에서 누구나 찾고 가입 신청할 수 있어요"
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
                        child: const Text("모임 만들기"),
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
