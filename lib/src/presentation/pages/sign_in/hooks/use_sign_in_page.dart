import "package:cupertino_ui/cupertino_ui.dart"
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 로그인 폼. 이메일과 비밀번호가 다 있고 로그인 중이 아니면 [canSubmit].
/// 로그인이 실패하면 스낵바로 알린다. [openSignUp]은 회원가입으로.
/// dev·staging에서는 로고를 7번 연속(2초 이내 간격) 누르면 테스트 계정 목록이 떠서,
/// 고른 계정의 이메일·비밀번호가 채워진다.
({
  TextEditingController email,
  TextEditingController password,
  bool loading,
  bool canSubmit,
  VoidCallback submit,
  VoidCallback notReady,
  VoidCallback openSignUp,
  VoidCallback onLogoTap,
})
useSignInPage(WidgetRef ref) {
  final context = useContext();

  final loading = ref.watch(signInViewModelProvider).isLoading;

  ref.listen(signInViewModelProvider, (_, next) {
    if (next case AsyncError(:final error)) {
      showAppSnackBar(
        context,
        error is AuthFailure ? error.message : "잠시 후 다시 시도해 주세요",
      );
    }
  });

  final email = useTextEditingController();

  final password = useTextEditingController();

  final taps = useRef(0);

  final lastTap = useRef(DateTime(0));

  // 입력할 때마다 다시 그려서 버튼이 입력을 따라간다.
  useListenable(Listenable.merge([email, password]));

  void onLogoTap() {
    // appFlavor는 const라 prod 빌드에서는 이 아래 코드(계정 문자열 포함)가 빠진다.
    if (appFlavor == "prod") return;

    final now = DateTime.now();

    final streak = now.difference(lastTap.value) < const Duration(seconds: 2);

    taps.value = streak ? taps.value + 1 : 1;

    lastTap.value = now;

    if (taps.value < 7) return;

    taps.value = 0;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("테스트 계정"),
        actions: [
          for (final account in _testAccounts)
            CupertinoActionSheetAction(
              onPressed: () {
                email.text = account.email;

                password.text = account.password;

                Navigator.of(context).pop();
              },
              child: Text("${account.label} (${account.email})"),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("닫기"),
        ),
      ),
    );
  }

  final filled = email.text.trim().isNotEmpty && password.text.isNotEmpty;

  return (
    email: email,
    password: password,
    loading: loading,
    canSubmit: filled && !loading,
    submit: () => ref
        .read(signInViewModelProvider.notifier)
        .signIn(email: email.text.trim(), password: password.text),
    // shortcut: 카카오·애플 로그인은 버튼만 있고 연결 전, 연결하면 각 ViewModel 호출로.
    notReady: () => showAppSnackBar(context, "준비 중인 기능이에요"),
    openSignUp: () => context.go("/signin/signup"),
    onLogoTap: onLogoTap,
  );
}

/// dev·staging 테스트 계정 (prod 빌드에서는 위 appFlavor 검사로 코드가 빠진다).
/// 그룹 가입 신청·수락은 두 계정을 바꿔 가며 확인한다.
const _testAccounts = [
  (label: "김정현", email: "tester@naver.com", password: "124312"),
  (label: "테스트 그룹장", email: "tester@weus.test", password: "weus1234!"),
];
