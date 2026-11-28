import "package:flutter/widgets.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons_500.dart";

/// 홈 바로가기 메뉴 목록 (최대 4개, 순서대로 왼쪽부터).
/// 전체 화면은 자기 탭으로 바꾸지 않고 홈 위에 쌓아서(push) 닫으면 홈으로 돌아온다.
/// 주소는 원래 탭 아래 그대로라 딥링크로 열면 그 탭 위에 열린다.
({List<({IconData icon, String label, VoidCallback onTap})> menus})
useHomePage() {
  final context = useContext();

  return (
    menus: [
      (
        icon: LucideIcons500.search,
        label: "그룹 찾기",
        onTap: () => context.push("/group/explore"),
      ),
      (
        icon: LucideIcons500.calendarPlus,
        label: "일정 등록하기",
        onTap: () => context.go("/schedule?add=1"),
      ),
      (
        icon: LucideIcons500.plus,
        label: "그룹 만들기",
        onTap: () => context.push("/group/new"),
      ),
      (
        icon: LucideIcons500.calendarDays,
        label: "내 일정",
        onTap: () => context.go("/schedule"),
      ),
    ],
  );
}
