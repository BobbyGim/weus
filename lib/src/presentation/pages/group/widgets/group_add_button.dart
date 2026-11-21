import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";

/// 모임 만들기 화면을 여는 플로팅 버튼.
class GroupAddButton extends StatelessWidget {
  const GroupAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      // 일정 탭의 버튼과 Hero 태그가 겹치지 않게.
      heroTag: null,
      tooltip: "모임 만들기",
      onPressed: () => context.go("/group/new"),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const CircleBorder(),
      child: const Icon(LucideIcons.plus, size: 24),
    );
  }
}
