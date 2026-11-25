import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "tab_scroll_reset.g.dart";

/// 하단 탭을 누를 때마다 바뀐다: 누른 탭의 경로와 누른 횟수 (같은 탭을 다시 눌러도 바뀌게).
@riverpod
class TabSelection extends _$TabSelection {
  @override
  ({String path, int count}) build() => (path: "", count: 0);

  void select(String path) => state = (path: path, count: state.count + 1);
}

/// 하단 탭으로 [path] 탭에 들어오거나 그 탭을 다시 누르면, [child] 안 목록의 스크롤
/// (컨트롤러 없이 만든 ListView 등이 쓰는 이 화면의 기본 스크롤)을 맨 위로 올린다.
/// 탭은 상태를 기억해서(indexedStack) 그냥 두면 내려 둔 위치부터 보인다.
class TabScrollReset extends ConsumerWidget {
  const TabScrollReset({super.key, required this.path, required this.child});

  final String path;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tabSelectionProvider, (_, next) {
      if (next.path != path) return;

      final controller = PrimaryScrollController.maybeOf(context);

      if (controller != null && controller.hasClients) controller.jumpTo(0);
    });

    return child;
  }
}
