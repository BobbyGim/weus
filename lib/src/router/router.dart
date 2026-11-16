import "dart:async";

import "package:flutter/cupertino.dart";
import "package:go_router/go_router.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:weus/src/presentation/pages/pages.dart";
import "package:weus/src/presentation/widgets/widgets.dart";

part "router.g.dart";

/// App router. Add routes here; auth redirects can `ref.watch` providers.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final rootKey = GlobalKey<NavigatorState>();

  // Completes shortly after the app is on screen: past the first frame at
  // launch, and resumed when it comes back from the background.
  // shortcut: fixed delay for the iOS app-open animation, wait for the startup
  // work (auth check) here too once there is some.
  Future<void> onScreen() async {
    await WidgetsBinding.instance.endOfFrame;

    final state = WidgetsBinding.instance.lifecycleState;

    if (state != null && state != AppLifecycleState.resumed) {
      final resumed = Completer<void>();

      final listener = AppLifecycleListener(onResume: resumed.complete);

      await resumed.future;

      listener.dispose();
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  var launching = true;

  onScreen().then((_) => launching = false);

  late final GoRouter router;

  router = GoRouter(
    navigatorKey: rootKey,
    // Deep link to a full screen (/mypage/info) while the app is not on screen
    // yet (cold start, or coming back from the background): go to its tab
    // first, then open it once the app is visible, so the user sees it slide
    // in instead of finding it already open.
    // shortcut: drops query parameters, pass state.uri.query once a page needs them.
    redirect: (_, state) {
      final segments = state.uri.pathSegments;

      final lifecycle = WidgetsBinding.instance.lifecycleState;

      final hidden =
          launching ||
          (lifecycle != null && lifecycle != AppLifecycleState.resumed);

      if (!hidden || segments.length < 2) return null;

      onScreen().then((_) => router.go(state.uri.path));

      return "/${segments.first}";
    },
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
