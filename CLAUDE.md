# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Flutter 3.50, Dart SDK ^3.14.0. Early stage: `lib/main.dart` (bootstrap, `MyApp`), `lib/src/` (router, domain, data, presentation), and `main_<flavor>.dart` entry files.

- Routing: `go_router`, exposed as `routerProvider` (`@Riverpod(keepAlive: true)`) in `lib/src/router/app_router.dart` (`router.dart` is the folder barrel); `MyApp` is a `ConsumerWidget` that watches it. Tabs (`/`, `/schedule`, `/meeting`, `/mypage`) are the branches of a `StatefulShellRoute.indexedStack` (`AppShell`, header + bottom nav), so each tab keeps its state; full-screen pages are child routes of their tab (`/mypage/info` under `/mypage`) with `parentNavigatorKey: rootKey` (covers the header/nav) and `pageBuilder` → `CupertinoPage` (slide + iOS swipe back), each written out, no helper, and are opened with `context.go`, so a deep link stacks them on their tab too (while the app is not on screen yet — cold start or returning from the background — `deepLinkRedirect` in `lib/src/router/deep_link_redirect.dart` opens the tab first, then slides the page in once the app is visible; `onScreen()` in `app_visibility.dart`). Add routes in `app_router.dart`; other redirect logic (e.g. auth) goes in its own file in `lib/src/router/`. `/` is the home page; no Flutter splash route.
- Hooks: `flutter_hooks` + `hooks_riverpod`. Import `package:hooks_riverpod/hooks_riverpod.dart` (re-exports flutter_riverpod; `flutter_riverpod` is not a direct dependency). Widgets needing `ref` + local state (controllers, animations, focus nodes) → `HookConsumerWidget` with `useTextEditingController()` etc. instead of `ConsumerStatefulWidget`; `ref` only → `ConsumerWidget`; neither → `StatelessWidget`. Shared state stays in providers, not hooks.
- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`); `bootstrap()` wraps the app in `ProviderScope`. Generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`) are gitignored — after a fresh clone or pull, run `dart run build_runner build -d` before building. `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`.
- Local DB: drift (`lib/src/data/database/`). `build.yaml` sets `store_date_time_values_as_text`, so `DateTime` columns are ISO-8601 TEXT (`DateTime.now()` → `2026-11-16T23:07:35.706 +09:00`). Schedule start/end store the picked day + the time of saving (same format as `created_at`); the repository turns them back into UTC-midnight dates for the app. Schema change → bump `schemaVersion` + add the step in `onUpgrade`.
- After changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, regenerate: `dart run build_runner build -d` (or `watch -d`).
- Icons: Lucide only (`lucide_icons_flutter`, `import "package:lucide_icons_flutter/lucide_icons.dart";` → `Icon(LucideIcons.calendarDays)`). Never Material `Icons.*` / `CupertinoIcons.*`, and no Material icon widgets (`CloseButton`, `BackButton` → `IconButton` with a Lucide icon). Lucide has no filled variants: show selected/active state with color, not a second icon.
- Font: Pretendard (400/500/600/700/800/900, `assets/fonts/`, OFL license alongside) is the theme default via `ThemeData(fontFamily: 'Pretendard')`. Other weights fall back to synthesized ones. Every `TextTheme` style sets `FontFeature.tabularFigures()` (all digits same width, app-wide) — keep it when adding styles.
- Lints: `flutter_lints` via `analysis_options.yaml`; `android/` and `ios/` are excluded from analysis.

## Flavors (dev / staging / prod)

| flavor | bundle / applicationId | app name | deep link |
|---|---|---|---|
| dev | `com.weus.weus.dev` | 위어스 dev | `weus-dev://app/<route>` |
| staging | `com.weus.weus.staging` | 위어스 stg | `weus-staging://app/<route>` |
| prod | `com.weus.weus` | 위어스 | `weus://app/<route>` |

- `flutter run --flavor staging -t lib/main_staging.dart` (entry files `main_<flavor>.dart` call `bootstrap('<flavor>')` in `main.dart`). Keep `--flavor` and `-t` matching. Plain `flutter run` → `dev` (`default-flavor` in pubspec, env from `appFlavor`).
- App-wide startup code goes in `bootstrap()` in `lib/main.dart`, not in the per-flavor entry files.
- Android: `productFlavors` in `android/app/build.gradle.kts`, label via `resValue("string","app_name")`.
- iOS: build configs `Debug-<flavor>` / `Release-<flavor>` / `Profile-<flavor>` + schemes `dev`/`staging`/`prod`. Bundle id and `APP_DISPLAY_NAME` (→ `CFBundleDisplayName`) are set per config in `project.pbxproj`. Adding a flavor means adding all three configs + a scheme.
- Env: `main.dart` loads `.env.$appFlavor` via `flutter_dotenv`. `.env.*` files are gitignored but declared as assets, so **a fresh clone must create `.env.dev`, `.env.staging`, `.env.prod` from `.env.example` before building**. Everything in them ships inside the app bundle — no real secrets.
- Icons & splash per flavor: prod = light (white bg, dark logo), dev/staging = inverted (dark `#111111` bg, white logo). Sources in `assets/logo/`; configs `flutter_launcher_icons-<flavor>.yaml` / `flutter_native_splash-<flavor>.yaml`. Regenerate with `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create --flavors dev,staging,prod`. iOS configs point at `AppIcon-<flavor>` and `LAUNCH_SCREEN_STORYBOARD=LaunchScreen<Flavor>` (Info.plist uses `$(LAUNCH_SCREEN_STORYBOARD)`); re-running the splash generator does not touch these.
- Splash is native only (no Flutter splash page): logo `splash_<light|dark>.png` (@4x, 180pt) + bottom wordmark `branding_<light|dark>.png` ("WeUs"); Android 12 uses `splash_a12_*.png` (1152px, logo kept inside the icon circle). If startup work is added (e.g. auth check), keep the native splash up with `FlutterNativeSplash.preserve()` / `remove()` instead of adding a splash route, so deep links land directly on their page.
- Deep links (custom scheme): host is always `app`, the path is the go_router route (`weus://app/schedule`). iOS: `APP_URL_SCHEME` per build config in `project.pbxproj` → `CFBundleURLTypes` in Info.plist. Android: `manifestPlaceholders["appScheme"]` per flavor → VIEW intent-filter in AndroidManifest. Test: `xcrun simctl openurl booted "<url>"` / `adb shell am start -a android.intent.action.VIEW -d "<url>"`.
- Android `compileSdk = 37` (required by `permission_handler`); `android.suppressUnsupportedCompileSdk=37` silences the AGP warning.

## Architecture

See @README.md (architecture, naming, hooks, MVVM, barrels, code style).

## Commands

```bash
flutter pub get                        # install deps
flutter pub add <pkg>                  # add a dependency
flutter run                            # run on connected device/emulator
flutter analyze                        # lint
dart format .                          # format
```

## Git

Remote is `https://BobbyGim@github.com/BobbyGim/weus.git` — the username in the URL makes git use the BobbyGim keychain credential (the machine's default GitHub account is a different one). Don't change the remote URL.

## Rules

- UI 작업(화면/위젯 디자인, 리디자인)을 할 때는 `taste-skill:design-taste-frontend` 스킬을 먼저 로드해서 따른다.
- UI/UX 작업(화면·위젯 구현, 애니메이션, 반응형 레이아웃, 테마)을 할 때는 `flutter-ui-ux` 스킬도 함께 로드해서 따른다.
- 코드를 작성/수정/리팩터링할 때는 `ponytail:ponytail` 스킬을 적용한다.
- 테스트 코드(`test/`, 위젯/유닛/골든 테스트 등)는 작성하지 않는다. 검증은 `flutter analyze`와 빌드/실행으로 한다. (ponytail의 "runnable check" 규칙보다 우선)
- 코드 주석(`//`, `///`)의 설명은 한글로 쓴다.

<!-- 프로젝트 규칙을 여기에 추가하세요. 예:
- 응답은 한국어로
- 상태관리는 Riverpod 사용
- 화면 파일은 lib/screens/ 에 둔다
-->
