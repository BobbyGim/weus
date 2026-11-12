import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

/// Header + bottom nav around the tab branches of the shell route in router.dart.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (label: "홈", icon: LucideIcons.house),
    (label: "일정", icon: LucideIcons.calendarDays),
    (label: "모임", icon: LucideIcons.users),
    (label: "마이페이지", icon: LucideIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset("assets/image/header_logo.png", height: 28),
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Re-tapping the current tab pops it back to its root.
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
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
