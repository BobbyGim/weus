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
          routes: [GoRoute(path: "/mypage", builder: (_, _) => const MyPage())],
        ),
      ],
    ),
  ],
);
