import "package:cupertino_ui/cupertino_ui.dart";
import "package:go_router/go_router.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/presentation/pages/pages.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

import "deep_link_redirect.dart";

part "app_router.g.dart";

/// 앱 라우터. 라우트 표만 두고, redirect 로직은 이 폴더의 다른 파일에 둔다.
/// auth redirect는 provider를 `ref.watch`할 수 있다.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final rootKey = GlobalKey<NavigatorState>();

  late final GoRouter router;

  router = GoRouter(
    navigatorKey: rootKey,
    redirect: deepLinkRedirect(() => router),
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
              GoRoute(
                path: "/schedule",
                builder: (_, _) => const SchedulePage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(path: "/meeting", builder: (_, _) => const MeetingPage()),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/mypage",
                builder: (_, _) => const MyPage(),
                // Full screens over the tabs (no header/nav): children of
                // their tab so a deep link stacks them on it, on the root
                // navigator via parentNavigatorKey. Open with context.go.
                // CupertinoPage slides in and keeps the iOS edge swipe back.
                routes: [
                  GoRoute(
                    path: "info",
                    parentNavigatorKey: rootKey,
                    pageBuilder: (_, state) => CupertinoPage(
                      key: state.pageKey,
                      child: const MyInfoPage(),
                    ),
                  ),

                  GoRoute(
                    path: "notifications",
                    parentNavigatorKey: rootKey,
                    pageBuilder: (_, state) => CupertinoPage(
                      key: state.pageKey,
                      child: const NotificationSettingsPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return router;
}
