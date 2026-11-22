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

    // shortcut: 카카오·애플 로그인은 버튼만 있고 연결 전, 연결하면 각 ViewModel 호출로.
    void notReady() => showAppSnackBar(context, "준비 중인 기능이에요");

    // 네이버 로그인처럼 키보드가 올라와도 화면은 그대로(키보드가 아래를 덮음).
    // 그래서 로고·입력칸·로그인 버튼을 위에서부터 쌓아 화면 위쪽 절반 안에 두고, 소셜
    // 로그인·회원가입은 맨 아래(키보드가 덮어도 되는 자리)에 둔다. 스크롤 없이 모든 화면에
    // 맞도록 로고만 남는 공간에 맞춰 줄어든다(최대 원래 크기).
    return AppLoadingOverlay(
      loading: loading,
      label: "로그인 중",
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: AutofillGroup(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              // 위 묶음(로고·입력칸·로그인)은 위에서부터, 아래 묶음(소셜·회원가입)은 맨 아래.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),

                        // 아래 묶음을 뺀 남는 공간에 맞춰, 모자라면 비율대로 줄어든다.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            // 스플래시처럼 로고 마크 아래에 워드마크 "WeUs".
                            // dev·staging은 7번 누르면 테스트 계정이 채워진다.
                            child: GestureDetector(
                              onTap: form.onLogoTap,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/image/logo_mark.png",
                                    height: 88,
                                    excludeFromSemantics: true,
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  Text(
                                    "WeUs",
                                    style: text.displaySmall!.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
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
                      ],
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      if (Theme.of(context).platform == TargetPlatform.iOS) ...[
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
