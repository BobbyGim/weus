import "package:flutter_hooks/flutter_hooks.dart";
import "package:material_ui/material_ui.dart";

/// 초대 코드 입력. [code]는 공백을 빼고 대문자로 바꾼 값이고, 8자리면 [filled].
/// [sending]은 가입 신청을 보내는 동안 true.
({
  TextEditingController input,
  String code,
  bool filled,
  ValueNotifier<bool> sending,
})
useGroupJoinPage() {
  final input = useTextEditingController();

  final sending = useState(false);

  // 입력할 때마다 다시 그려서 버튼과 찾은 결과가 입력을 따라간다.
  useListenable(input);

  final code = input.text.trim().toUpperCase();

  return (input: input, code: code, filled: code.length == 8, sending: sending);
}
