import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 가입 폼. 이름·이메일이 있고 비밀번호가 6자 이상(Supabase 최소 길이)이면
/// 가입할 수 있다. 비밀번호 확인이 다르면 [mismatch]. 비밀번호는 가려진 채
/// 시작하고 눈 버튼으로 두 칸 다 보이게 한다. 가입 중이 아니고 다 채우면
/// [canSubmit], 가입이 실패하면 스낵바로 알린다.
({
  TextEditingController name,
  TextEditingController email,
  TextEditingController password,
  TextEditingController confirm,
  bool mismatch,
  bool obscure,
  VoidCallback toggleObscure,
  bool loading,
  bool canSubmit,
  VoidCallback submit,
})
useSignUpPage(WidgetRef ref) {
  final context = useContext();

  final loading = ref.watch(signUpViewModelProvider).isLoading;

  ref.listen(signUpViewModelProvider, (_, next) {
    if (next case AsyncError(:final error)) {
      showAppSnackBar(
        context,
        error is AuthFailure ? error.message : "잠시 후 다시 시도해 주세요",
      );
    }
  });

  final name = useTextEditingController();

  final email = useTextEditingController();

  final password = useTextEditingController();

  final confirm = useTextEditingController();

  final obscure = useState(true);

  // 입력할 때마다 다시 그려서 버튼이 입력을 따라간다.
  useListenable(Listenable.merge([name, email, password, confirm]));

  // 확인 칸에 입력을 시작한 뒤에만 다르다고 알린다.
  final mismatch = confirm.text.isNotEmpty && confirm.text != password.text;

  final filled =
      name.text.trim().isNotEmpty &&
      email.text.trim().isNotEmpty &&
      password.text.length >= 6 &&
      confirm.text == password.text;

  return (
    name: name,
    email: email,
    password: password,
    confirm: confirm,
    mismatch: mismatch,
    obscure: obscure.value,
    toggleObscure: () => obscure.value = !obscure.value,
    loading: loading,
    canSubmit: filled && !loading,
    submit: () => ref
        .read(signUpViewModelProvider.notifier)
        .signUp(
          name: name.text.trim(),
          email: email.text.trim(),
          password: password.text,
        ),
  );
}
