import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";
import "package:weus/src/domain/domain.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "../view_models/view_models.dart";

/// 글쓰기 폼. 제목은 앞뒤 공백을 빼고 비어 있지 않아야 올릴 수 있다 (본문은 없어도
/// 된다). [sending]은 올리는 동안 true. [send]는 올릴 수 있을 때만 있다 (아니면
/// null, 버튼이 꺼진다). 올리면 스낵바를 띄우고 true를 돌려주며 닫는다.
({
  TextEditingController titleInput,
  TextEditingController descriptionInput,
  bool sending,
  VoidCallback? send,
})
useGroupPostNewPage(WidgetRef ref, int groupId) {
  final context = useContext();

  final titleInput = useTextEditingController();

  final descriptionInput = useTextEditingController();

  final sending = useState(false);

  final provider = groupPostNewViewModelProvider(groupId);

  // clientId를 화면이 열려 있는 동안 유지한다.
  ref.watch(provider);

  final viewModel = ref.read(provider.notifier);

  // 제목을 입력할 때마다 다시 그려서 올리기 버튼이 입력을 따라간다.
  useListenable(titleInput);

  final title = titleInput.text.trim();

  Future<void> send() async {
    sending.value = true;

    try {
      await viewModel.post(
        title: title,
        description: descriptionInput.text.trim(),
      );

      if (!context.mounted) return;

      showAppSnackBar(context, "글을 올렸어요", icon: LucideIcons.circleCheck);

      context.canPop() ? context.pop(true) : context.go("/group/$groupId");
    } on GroupFailure catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } catch (_) {
      if (context.mounted) showAppSnackBar(context, "잠시 후 다시 시도해 주세요");
    } finally {
      if (context.mounted) sending.value = false;
    }
  }

  return (
    titleInput: titleInput,
    descriptionInput: descriptionInput,
    sending: sending.value,
    send: title.isNotEmpty && !sending.value ? send : null,
  );
}
