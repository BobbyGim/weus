import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";

/// 가입 폼. 이름·이메일이 있고 비밀번호가 6자 이상(Supabase 최소 길이)이면
/// 가입할 수 있다. 비밀번호 확인이 다르면 [mismatch]. 비밀번호는 가려진 채
/// 시작하고 눈 버튼으로 두 칸 다 보이게 한다.
({
  TextEditingController name,
  TextEditingController email,
  TextEditingController password,
  TextEditingController confirm,
  bool mismatch,
  bool obscure,
  VoidCallback toggleObscure,
  bool filled,
})
useSignUpPage() {
  final name = useTextEditingController();

  final email = useTextEditingController();

  final password = useTextEditingController();

  final confirm = useTextEditingController();

  final obscure = useState(true);

  // 입력할 때마다 다시 그려서 버튼이 입력을 따라간다.
  useListenable(Listenable.merge([name, email, password, confirm]));

  // 확인 칸에 입력을 시작한 뒤에만 다르다고 알린다.
  final mismatch = confirm.text.isNotEmpty && confirm.text != password.text;

  return (
    name: name,
    email: email,
    password: password,
    confirm: confirm,
    mismatch: mismatch,
    obscure: obscure.value,
    toggleObscure: () => obscure.value = !obscure.value,
    filled:
        name.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        password.text.length >= 6 &&
        confirm.text == password.text,
  );
}
