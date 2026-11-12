import "package:flutter/cupertino.dart";
import "package:go_router/go_router.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:weus/src/presentation/pages/pages.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

part "router.g.dart";

/// App router. Add routes here; auth redirects can `ref.watch` providers.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(
  routes: [
    // Tabs with header + bottom nav. indexedStack keeps each tab's state.
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: "/", builder: (_, _) => const HomePage())],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(path: "/schedule", builder: (_, _) => const SchedulePage()),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(path: "/meeting", builder: (_, _) => const MeetingPage()),
          ],
        ),

        StatefulShellBranch(
          routes: [GoRoute(path: "/mypage", builder: (_, _) => const MyPage())],
        ),
      ],
    ),

    // Outside the shell: full screens pushed over the tabs (no header/nav).
    // Open them with context.push so back returns to the tab. CupertinoPage
    // slides in from the right and keeps the iOS edge swipe back.
    GoRoute(
      path: "/mypage/info",
      pageBuilder: (_, state) =>
          CupertinoPage(key: state.pageKey, child: const MyInfoPage()),
    ),

    GoRoute(
      path: "/mypage/notifications",
      pageBuilder: (_, state) => CupertinoPage(
        key: state.pageKey,
        child: const NotificationSettingsPage(),
      ),
    ),
  ],
);
