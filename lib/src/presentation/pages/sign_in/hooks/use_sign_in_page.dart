import "package:cupertino_ui/cupertino_ui.dart"
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";

/// 로그인 폼. 이메일과 비밀번호가 다 있으면 로그인할 수 있다.
/// dev·staging에서는 로고를 7번 연속(2초 이내 간격) 누르면 테스트 계정 목록이 떠서,
/// 고른 계정의 이메일·비밀번호가 채워진다.
({
  TextEditingController email,
  TextEditingController password,
  bool filled,
  VoidCallback onLogoTap,
})
useSignInPage() {
  final context = useContext();

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

  return (
    email: email,
    password: password,
    filled: email.text.trim().isNotEmpty && password.text.isNotEmpty,
    onLogoTap: onLogoTap,
  );
}

/// dev·staging 테스트 계정 (prod 빌드에서는 위 appFlavor 검사로 코드가 빠진다).
/// 그룹 가입 신청·수락은 두 계정을 바꿔 가며 확인한다.
const _testAccounts = [
  (label: "김정현", email: "tester@naver.com", password: "124312"),
  (label: "테스트 그룹장", email: "tester@weus.test", password: "weus1234!"),
];
