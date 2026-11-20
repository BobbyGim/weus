import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";

/// 로그인 폼. 이메일과 비밀번호가 다 있으면 로그인할 수 있다.
({TextEditingController email, TextEditingController password, bool filled})
useSignInPage() {
  final email = useTextEditingController();

  final password = useTextEditingController();

  // 입력할 때마다 다시 그려서 버튼이 입력을 따라간다.
  useListenable(Listenable.merge([email, password]));

  return (
    email: email,
    password: password,
    filled: email.text.trim().isNotEmpty && password.text.isNotEmpty,
  );
}
