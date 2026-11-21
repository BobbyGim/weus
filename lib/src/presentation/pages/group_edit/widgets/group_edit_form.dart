import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/data/data.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";
import "hooks/hooks.dart";

/// 모임 수정 폼 (지금 값으로 채워진 이름·카테고리·소개와 맨 아래 저장 버튼).
/// 저장하면 true를 돌려주며 닫힌다 (상세가 다시 불러온다).
class GroupEditForm extends HookConsumerWidget {
  const GroupEditForm({super.key, required this.detail});

  final GroupDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupEditForm(detail);

    final categories = ref.watch(groupCategoriesProvider).value ?? const [];

    Future<void> save() async {
      final saved = await form.run(
        () => ref
            .read(groupEditViewModelProvider(detail.id).notifier)
            .save(
              name: form.name.text.trim(),
              description: form.description.text.trim(),
              categories: form.categories,
            ),
      );

      if (!saved || !context.mounted) return;

      showAppSnackBar(context, "그룹을 수정했어요", icon: LucideIcons.circleCheck);

      context.pop(true);
    }

    // 칸은 위에, 저장 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: form.busy,
      label: "저장 중",
      child: SafeArea(
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

                    const Spacer(),

                    const SizedBox(height: AppSpacing.xxxl),

                    FilledButton(
                      onPressed: form.canSave ? save : null,
                      child: const Text("저장"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
