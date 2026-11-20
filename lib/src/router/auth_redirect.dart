import "package:go_router/go_router.dart";
import "package:weus/src/domain/domain.dart";

/// 로그인 안 했으면 로그인 화면(/signin, 가입은 /signin/signup)으로, 로그인했는데
/// 그 화면들에 있으면 홈으로 보낸다.
// shortcut: 로그인 전에 들어온 딥링크는 버리고 홈으로 간다, 로그인 뒤 그
// 페이지로 가야 하면 원래 경로를 query로 넘긴다.
GoRouterRedirect authRedirect(AuthRepository auth) => (_, state) {
  final onSignIn = state.uri.path.startsWith("/signin");

  if (!auth.signedIn) return onSignIn ? null : "/signin";

  return onSignIn ? "/" : null;
};
