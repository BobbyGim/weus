import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 초대 코드로 참여. [input]은 코드 입력칸, [found]는 지금 입력한 코드로 찾은 그룹
/// (코드를 바꾸면 null). [loading]은 찾거나 신청하는 동안 true.
/// [find]는 8자리를 다 쳤고 요청 중이 아닐 때만, [send](가입 신청)는 요청 중이
/// 아닐 때만 있다 (아니면 null, 버튼이 꺼진다). 신청하면 스낵바를 띄우고 닫는다.
({
  TextEditingController input,
  GroupPreview? found,
  bool loading,
  VoidCallback? find,
  VoidCallback? send,
})
useGroupJoinPage(WidgetRef ref) {
  final context = useContext();

  final input = useTextEditingController();

  final sending = useState(false);

  final state = ref.watch(groupJoinViewModelProvider);

  final viewModel = ref.read(groupJoinViewModelProvider.notifier);

  ref.listen(groupJoinViewModelProvider, (_, next) {
    if (next case AsyncError(:final error)) {
      showAppSnackBar(
        context,
        error is GroupFailure ? error.message : "잠시 후 다시 시도해 주세요",
      );
    }
  });

  // 입력할 때마다 다시 그려서 버튼과 찾은 결과가 입력을 따라간다.
  useListenable(input);

  // 공백을 빼고 대문자로 바꾼 코드.
  final code = input.text.trim().toUpperCase();

  // 지금 입력한 코드로 찾은 결과만 보여준다.
  final found = state.value?.code == code ? state.value?.preview : null;

  final loading = state.isLoading || sending.value;

  Future<void> send() async {
    sending.value = true;

    try {
      await viewModel.request(code);

      if (!context.mounted) return;

      showAppSnackBar(
        context,
        "가입을 신청했어요. 그룹장이 수락하면 참여돼요",
        icon: LucideIcons.circleCheck,
      );

      context.canPop() ? context.pop() : context.go("/group");
    } on GroupFailure catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, "잠시 후 다시 시도해 주세요");
    } finally {
      if (context.mounted) sending.value = false;
    }
  }

  return (
    input: input,
    found: found,
    loading: loading,
    find: code.length == 8 && !loading ? () => viewModel.find(code) : null,
    send: loading ? null : send,
  );
}
