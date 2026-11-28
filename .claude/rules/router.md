---
paths:
  - "lib/src/router/**/*.dart"
---

# Routing & Deep Links

## 파일

| 파일 | 하는 일 |
|---|---|
| `router.dart` | barrel |
| `app_router.dart` | 라우트 표 (`routerProvider`) |
| `auth_redirect.dart` | 로그인 여부 redirect |
| `deep_link_redirect.dart` | 딥링크 redirect |
| `app_visibility.dart` | 앱이 화면에 보일 때까지 대기 (`onScreen`) |
| `sheet_page.dart` | 아래에서 올라오는 iOS 시트 페이지 |
| `bottom_sheet_page.dart` | 아래에서 내용만큼 올라오는 바텀시트 페이지 |

## 화면 종류

| 종류 | 예 | 여는 방법 | 닫으면 |
|---|---|---|---|
| 탭 | `/`, `/schedule`, `/group`, `/mypage` | 하단 탭 | - (탭마다 상태 유지, 탭을 누르면 맨 위로 스크롤) |
| 탭 위 전체 화면 | `/mypage/info`, `/group/new`, `/group/join`, `/group/explore`, `/group/explore/:id`, `/group/:id`, `/group/:id/settings`, `/group/:id/post/new`, `/group/:id/post/:postId` | `context.go` (자기 탭 아래 라우트) | 그 탭으로 |

## 규칙

- Routing: `go_router`, exposed as `routerProvider` (`@Riverpod(keepAlive: true)`) in `lib/src/router/app_router.dart` (`router.dart` is the folder barrel); `MyApp` is a `ConsumerWidget` that watches it.
- Tabs (`/`, `/schedule`, `/group`, `/mypage`) are the branches of a `StatefulShellRoute.indexedStack` (`AppShell`, header + bottom nav), so each tab keeps its state (탭을 누르면 맨 위로 스크롤).
- Full-screen pages are child routes of their tab (`/mypage/info` under `/mypage`) with `parentNavigatorKey: rootKey` (covers the header/nav) and `pageBuilder` → `CupertinoPage` (slide + iOS swipe back), each written out, no helper, and are opened with `context.go`, so a deep link stacks them on their tab too.
- 다른 탭에서 열 때는 `context.push`로 지금 화면 위에 쌓는다 (홈의 "모임 찾기"는 홈 위에 열리고 닫으면 홈, 같은 주소를 딥링크로 열면 모임 탭 위).
- 모임 미리보기(`/group/explore/:id`)와 그룹 상세(`/group/:id`)는 아래에서 올라오는 iOS 시트다 (`SheetPage`, 아래로 끌면 닫힘). 내용만큼 올라오는 바텀시트는 `bottom_sheet_page.dart`.
- 모임 찾기 검색어는 주소 쿼리로 남는다 (`/group/explore?q=러닝`). 검색할 때는 `replace`라 뒤로가기에 검색 기록이 쌓이지 않는다.
- Add routes in `app_router.dart`; other redirect logic (e.g. auth) goes in its own file in `lib/src/router/`. `/` is the home page; no Flutter splash route.

## Deep links

주소는 `<scheme>://app/<route>` (scheme은 flavor별, 루트 CLAUDE.md 표). Host is always `app`, the path is the go_router route.

- 앱이 켜져 있으면 그 주소로 이동한다 (전체 화면은 자기 탭 위에 쌓임).
- While the app is not on screen yet — cold start or returning from the background — `deepLinkRedirect` in `deep_link_redirect.dart` opens the tab first, then slides the page in once the app is visible (`onScreen()` in `app_visibility.dart`).
- 로그인 전에 들어온 딥링크는 로그인 화면으로 간다 (`auth_redirect.dart`).
- 그룹 상세 링크를 멤버가 아닌 사람이 열면 미리보기로 바뀐다 (공개 모임이면 가입 신청, 아니면 없는 모임).

## 딥링크 테스트

```bash
# 시뮬레이터 (simctl은 시뮬레이터에서만 동작)
xcrun simctl openurl booted "weus-staging://app/group/explore"

# 실기기 (기기 ID는 `xcrun xctrace list devices`)
xcrun devicectl device process launch --device <기기 ID> \
  --payload-url "weus-staging://app/group/explore" com.weus.weus.staging

# Android
adb shell am start -a android.intent.action.VIEW -d "weus-staging://app/group/explore"
```

- 한글 검색어는 인코딩해서 넣는다 (`?q=%EC%9A%94%EA%B0%80` = 요가).
- 실기기에서는 Safari 주소창에 주소를 입력해도 열린다.
