import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "view_models/view_models.dart";

/// 이름·이메일·비밀번호로 가입. 가입하면 바로 로그인돼 라우터가 홈으로 보낸다.
class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useSignUpPage();

    final loading = ref.watch(signUpViewModelProvider).isLoading;

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    ref.listen(signUpViewModelProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showAppSnackBar(
          context,
          error is AuthFailure ? error.message : "잠시 후 다시 시도해 주세요",
        );
      }
    });

    void submit() => ref
        .read(signUpViewModelProvider.notifier)
        .signUp(
          name: form.name.text.trim(),
          email: form.email.text.trim(),
          password: form.password.text,
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

    // 칸은 위에, 가입 버튼은 맨 아래(키보드가 올라오면 키보드 바로 위).
    return AppLoadingOverlay(
      loading: loading,
      label: "가입 중",
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const AppBackButton(fallback: "/signin"),
          title: const Text("회원가입"),
        ),
        body: SafeArea(
          top: false,
          child: AutofillGroup(
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
                          "이름",
                          TextField(
                            controller: form.name,
                            // profiles.name 길이 제한과 같다.
                            maxLength: 50,
                            autofillHints: const [AutofillHints.name],
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: "홍길동",
                              counterText: "",
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        labeled(
                          "이메일",
                          TextField(
                            controller: form.email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: "example@email.com",
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        labeled(
                          "비밀번호",
                          TextField(
                            controller: form.password,
                            obscureText: form.obscure,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: "6자 이상",
                              suffixIcon: IconButton(
                                tooltip: form.obscure ? "비밀번호 보기" : "비밀번호 숨기기",
                                onPressed: form.toggleObscure,
                                icon: Icon(
                                  form.obscure
                                      ? LucideIcons.eye
                                      : LucideIcons.eyeOff,
                                  size: 20,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        labeled(
                          "비밀번호 확인",
                          TextField(
                            controller: form.confirm,
                            obscureText: form.obscure,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (canSubmit) submit();
                            },
                            decoration: InputDecoration(
                              hintText: "비밀번호를 한 번 더 입력",
                              errorText: form.mismatch
                                  ? "비밀번호가 일치하지 않아요"
                                  : null,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: AppSpacing.xxxl),

                        FilledButton(
                          onPressed: canSubmit ? submit : null,
                          child: const Text("가입하기"),
                        ),
                      ],
                    ),
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
