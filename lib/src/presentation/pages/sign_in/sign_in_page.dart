import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/theme/theme.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "hooks/hooks.dart";
import "view_models/view_models.dart";
import "widgets/widgets.dart";

/// 이메일·비밀번호 로그인. 로그인 안 했으면 라우터가 여기로 보낸다.
class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useSignInPage();

    final loading = ref.watch(signInViewModelProvider).isLoading;

    final scheme = Theme.of(context).colorScheme;

    final text = Theme.of(context).textTheme;

    ref.listen(signInViewModelProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showAppSnackBar(
          context,
          error is AuthFailure ? error.message : "잠시 후 다시 시도해 주세요",
        );
      }
    });

    void submit() => ref
        .read(signInViewModelProvider.notifier)
        .signIn(email: form.email.text.trim(), password: form.password.text);

    final canSubmit = form.filled && !loading;

    // 작은 폰(SE 667pt)에서도 스크롤 없이 들어가게 로고를 화면 높이에 맞춰 줄인다.
    // 844pt(iPhone 14) 이상은 원래 크기. 키보드가 올라와도 바뀌지 않는 화면 높이 기준.
    final logoScale = (MediaQuery.sizeOf(context).height / 844).clamp(
      0.75,
      1.0,
    );

    // shortcut: 카카오·애플 로그인은 버튼만 있고 연결 전, 연결하면 각 ViewModel 호출로.
    void notReady() => showAppSnackBar(context, "준비 중인 기능이에요");

    // 로고는 남는 공간의 가운데, 폼은 아래쪽. 키보드가 올라와 공간이 모자라면
    // 로고 영역이 줄어들고 그래도 모자라면 스크롤된다.
    return AppLoadingOverlay(
      loading: loading,
      label: "로그인 중",
      child: Scaffold(
        body: SafeArea(
          child: AutofillGroup(
            child: CustomScrollView(
              // 화면에 다 들어가면 스크롤·바운스 없음. 키보드에 가려질 때만 스크롤된다.
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            // 스플래시처럼 로고 마크 아래에 워드마크 "WeUs".
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/image/logo_mark.png",
                                  height: 88 * logoScale,
                                  excludeFromSemantics: true,
                                ),

                                SizedBox(height: AppSpacing.lg * logoScale),

                                Text(
                                  "WeUs",
                                  style: text.displaySmall!.copyWith(
                                    fontSize: 28 * logoScale,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxxl),

                        TextField(
                          controller: form.email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(hintText: "이메일"),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        TextField(
                          controller: form.password,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (canSubmit) submit();
                          },
                          decoration: const InputDecoration(hintText: "비밀번호"),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        FilledButton(
                          onPressed: canSubmit ? submit : null,
                          child: const Text("로그인"),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        Row(
                          children: [
                            const Expanded(child: Divider()),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                "또는",
                                style: text.bodySmall!.copyWith(
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),

                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        SocialSignInButton.kakao(onPressed: notReady),

                        // 국내 앱들처럼 Apple 로그인은 iOS에서만.
                        if (Theme.of(context).platform ==
                            TargetPlatform.iOS) ...[
                          const SizedBox(height: AppSpacing.sm),

                          SocialSignInButton.apple(onPressed: notReady),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "아직 회원이 아니신가요?",
                              style: text.bodyMedium!.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),

                            TextButton(
                              onPressed: () => context.go("/signin/signup"),
                              child: const Text("회원가입"),
                            ),
                          ],
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
