import "package:material_ui/material_ui.dart";

/// 화면 오른쪽 아래의 둥근 파란 버튼 (그룹 만들기, 글쓰기, 일정 등록).
/// [child]를 주면 [icon] 대신 그린다 (예: 속을 칠한 연필).
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
  }) : assert(icon != null || child != null);

  final String tooltip;

  final VoidCallback onPressed;

  final IconData? icon;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      // 탭·시트마다 하나씩 동시에 보일 수 있어서 Hero를 쓰지 않는다.
      heroTag: null,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: const CircleBorder(),
      child: child ?? Icon(icon, size: 24),
    );
  }
}
