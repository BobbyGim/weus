import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";

/// 모임 이름·소개를 받아 모임을 만든다. 만든 사람이 owner가 되고, 만들면 모임 탭으로 돌아간다.
class GroupCreatePage extends HookConsumerWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupCreatePage(ref);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // 칸은 스크롤, 만들기 버튼은 맨 아래 고정(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: form.loading,
      label: "그룹 만드는 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/group"),
          title: const Text("그룹 만들기"),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  // 화면에 다 들어가면 스크롤·바운스 없음.
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  children: [
                    GroupFormFields(
                      name: form.name,
                      description: form.description,
                      categories: form.options,
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
                  onPressed: form.submit,
                  child: const Text("그룹 만들기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
