import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "app_visibility.dart";

/// 앱이 아직 화면에 없을 때(콜드 스타트, 백그라운드에서 복귀) 들어온 풀스크린
/// 딥링크(/mypage/info)는 먼저 그 탭으로 보내고, 앱이 보이면 페이지를 연다.
/// 이미 열려 있는 페이지가 아니라 슬라이드로 들어오는 페이지를 보게 하려는 것.
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

    // 딥링크(weus://app/group/explore?q=…)에서 앱 안 주소(/group/explore?q=…)만.
    final location = Uri(
      path: state.uri.path,
      query: state.uri.hasQuery ? state.uri.query : null,
    ).toString();

    if (kDebugMode) {
      debugPrint("[deeplink] 꺼진 앱: /${segments.first} → go $location");
    }

    onScreen().then((_) => router().go(location));

    return "/${segments.first}";
  };
}
