import "package:material_ui/material_ui.dart";

import "home_quick_menu_item.dart";

/// 홈 바로가기 한 줄의 칸 수. 메뉴가 모자라면 남는 칸은 비워 둔다.
const _slots = 4;

/// 홈의 바로가기 메뉴. [items]가 4칸 한 줄에 왼쪽부터 놓인다.
class HomeQuickMenu extends StatelessWidget {
  const HomeQuickMenu({super.key, required this.items})
    : assert(items.length <= _slots, "바로가기는 최대 $_slots개");

  final List<HomeQuickMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _slots; i++)
          Expanded(
            child: i < items.length ? items[i] : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
