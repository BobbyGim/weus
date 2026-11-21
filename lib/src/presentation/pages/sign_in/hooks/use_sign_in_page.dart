import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";

/// 로그인 폼. 이메일과 비밀번호가 다 있으면 로그인할 수 있다.
/// dev·staging에서는 로고를 7번 연속(2초 이내 간격) 누르면 테스트 계정이 채워진다.
({
  TextEditingController email,
  TextEditingController password,
  bool filled,
  VoidCallback onLogoTap,
})
useSignInPage() {
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

    email.text = "tester@naver.com";

    password.text = "124312";
  }

  return (
    email: email,
    password: password,
    filled: email.text.trim().isNotEmpty && password.text.isNotEmpty,
    onLogoTap: onLogoTap,
  );
}
