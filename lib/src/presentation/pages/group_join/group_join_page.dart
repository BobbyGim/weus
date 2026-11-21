import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "view_models/view_models.dart";

/// 초대 코드로 모임을 찾아 가입 신청한다. 모임장이 수락하면 멤버가 된다
/// (나갔거나 내보내진 모임도 다시 신청할 수 있다).
class GroupJoinPage extends HookConsumerWidget {
  const GroupJoinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useGroupJoinPage();

    final state = ref.watch(groupJoinViewModelProvider);

    final viewModel = ref.read(groupJoinViewModelProvider.notifier);

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    // 지금 입력한 코드로 찾은 결과만 보여준다.
    final found = state.value?.code == form.code ? state.value?.preview : null;

    ref.listen(groupJoinViewModelProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showAppSnackBar(
          context,
          error is GroupFailure ? error.message : "잠시 후 다시 시도해 주세요",
        );
      }
    });

    Future<void> send() async {
      form.sending.value = true;

      try {
        await viewModel.request(form.code);

        if (!context.mounted) return;

        showAppSnackBar(
          context,
          "가입을 신청했어요. 모임장이 수락하면 참여돼요",
          icon: LucideIcons.circleCheck,
        );

        context.canPop() ? context.pop() : context.go("/group");
      } on GroupFailure catch (e) {
        if (context.mounted) showAppSnackBar(context, e.message);
      } catch (_) {
        if (context.mounted) showAppSnackBar(context, "잠시 후 다시 시도해 주세요");
      } finally {
        if (context.mounted) form.sending.value = false;
      }
    }

    final loading = state.isLoading || form.sending.value;

    // 칸과 찾은 모임은 위에, 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: loading,
      label: found == null ? "모임 찾는 중" : "가입 신청 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/group"),
          title: const Text("초대 코드로 참여"),
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
                      Text(
                        "초대 코드",
                        style: text.titleSmall!.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      TextField(
                        controller: form.input,
                        maxLength: 8,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) {
                          if (form.filled && !loading && found == null) {
                            viewModel.find(form.code);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "모임에서 받은 8자리 코드",
                          counterText: "",
                        ),
                      ),

                      if (found != null) ...[
                        const SizedBox(height: AppSpacing.xxl),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(found.name, style: text.titleMedium),

                                const SizedBox(height: AppSpacing.xs),

                                Text(
                                  "멤버 ${found.memberCount}명",
                                  style: text.bodyMedium!.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),

                                if (found.description.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),

                                  Text(
                                    found.description,
                                    style: text.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      const SizedBox(height: AppSpacing.xxxl),

                      if (found == null)
                        FilledButton(
                          onPressed: form.filled && !loading
                              ? () => viewModel.find(form.code)
                              : null,
                          child: const Text("모임 찾기"),
                        )
                      else
                        FilledButton(
                          onPressed: loading ? null : send,
                          child: const Text("가입 신청"),
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
