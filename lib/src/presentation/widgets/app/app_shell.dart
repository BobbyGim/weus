import "package:go_router/go_router.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:material_ui/material_ui.dart";

import "tab_scroll_reset.dart";

/// Header + bottom nav around the tab branches of the shell route in router.dart.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (label: "홈", icon: LucideIcons.house, path: "/"),
    (label: "일정", icon: LucideIcons.calendarDays, path: "/schedule"),
    (label: "그룹", icon: LucideIcons.users, path: "/group"),
    (label: "마이페이지", icon: LucideIcons.user, path: "/mypage"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset("assets/image/header_logo.png", height: 28),
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Re-tapping the current tab pops it back to its root. 어느 탭이든 누르면
        // 그 탭 목록을 맨 위로 (TabScrollReset).
        onDestinationSelected: (i) {
          shell.goBranch(i, initialLocation: i == shell.currentIndex);

          ref.read(tabSelectionProvider.notifier).select(_tabs[i].path);
        },
        destinations: [
          for (final t in _tabs)
            // Lucide has no filled variant: the selected tab differs by
            // color only (navigationBarTheme).
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}
