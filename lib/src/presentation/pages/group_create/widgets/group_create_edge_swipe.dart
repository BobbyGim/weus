import "package:material_ui/material_ui.dart";

/// iOS 뒤로가기 끌기처럼 왼쪽 가장자리에서 시작한 끌기만 받는 투명한 띠.
/// Stack 안에서 단계 내용 위에 놓는다. 탭은 아래 위젯으로 그대로 간다.
class GroupCreateEdgeSwipe extends StatelessWidget {
  const GroupCreateEdgeSwipe({
    super.key,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
  });

  final GestureDragUpdateCallback onUpdate;

  final GestureDragEndCallback onEnd;

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      // iOS 뒤로가기 끌기가 시작되는 폭과 같다.
      width: 20,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: onUpdate,
        onHorizontalDragEnd: onEnd,
        onHorizontalDragCancel: onCancel,
      ),
    );
  }
}
