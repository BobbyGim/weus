import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "app_visibility.dart";

/// 앱이 아직 화면에 없을 때(콜드 스타트, 백그라운드에서 복귀) 들어온 풀스크린
/// 딥링크(/mypage/info)는 먼저 그 탭으로 보내고, 앱이 보이면 페이지를 연다.
/// 이미 열려 있는 페이지가 아니라 슬라이드로 들어오는 페이지를 보게 하려는 것.
// shortcut: query 파라미터를 버림, 페이지가 필요해지면 state.uri.query를 넘긴다.
GoRouterRedirect deepLinkRedirect(GoRouter Function() router) {
  var launching = true;

  onScreen().then((_) => launching = false);

  return (_, state) {
    final segments = state.uri.pathSegments;

    final lifecycle = WidgetsBinding.instance.lifecycleState;

    final hidden =
        launching ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed);

    if (!hidden || segments.length < 2) return null;

    onScreen().then((_) => router().go(state.uri.path));

    return "/${segments.first}";
  };
}
