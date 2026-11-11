# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Dart SDK ^3.13.5. Early stage: `lib/main.dart` (bootstrap, `MyApp`), `lib/src/` (router, domain, data, presentation), and `main_<flavor>.dart` entry files.

- Routing: `go_router`, exposed as `routerProvider` (`@Riverpod(keepAlive: true)`) in `lib/src/router.dart`; `MyApp` is a `ConsumerWidget` that watches it. Tabs (`/`, `/schedule`, `/mypage`) are the branches of a `StatefulShellRoute.indexedStack` (`AppShell`, header + bottom nav), so each tab keeps its state; full-screen pages go outside the shell as top-level routes with `pageBuilder` → `CupertinoPage` (slide + iOS swipe back), each written out, no helper, and are opened with `context.push`. Add routes there. `/` is the home page; no Flutter splash route.
- Hooks: `flutter_hooks` + `hooks_riverpod`. Import `package:hooks_riverpod/hooks_riverpod.dart` (re-exports flutter_riverpod; `flutter_riverpod` is not a direct dependency). Widgets needing `ref` + local state (controllers, animations, focus nodes) → `HookConsumerWidget` with `useTextEditingController()` etc. instead of `ConsumerStatefulWidget`; `ref` only → `ConsumerWidget`; neither → `StatelessWidget`. Shared state stays in providers, not hooks.
- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`); `bootstrap()` wraps the app in `ProviderScope`. Generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`) are gitignored — after a fresh clone or pull, run `dart run build_runner build -d` before building. `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`.
- After changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, regenerate: `dart run build_runner build -d` (or `watch -d`).
- Icons: Lucide only (`lucide_icons_flutter`, `import "package:lucide_icons_flutter/lucide_icons.dart";` → `Icon(LucideIcons.calendarDays)`). Never Material `Icons.*` / `CupertinoIcons.*`, and no Material icon widgets (`CloseButton`, `BackButton` → `IconButton` with a Lucide icon). Lucide has no filled variants: show selected/active state with color, not a second icon.
- Font: Pretendard (400/500/600/700/800/900, `assets/fonts/`, OFL license alongside) is the theme default via `ThemeData(fontFamily: 'Pretendard')`. Other weights fall back to synthesized ones.
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

## Architecture (layer-first clean architecture, pages split under presentation)

```
lib/
├── main.dart, main_<flavor>.dart   # bootstrap + flavor entries
└── src/
    ├── router.dart                 # routerProvider
    ├── domain/                     # shared by every page; pure Dart, no Flutter/data imports
    │   ├── domain.dart             # barrel
    │   ├── entities/               # (add when needed)
    │   └── repositories/           # repository interfaces (<name>_repository.dart)
    ├── data/                       # shared; DTOs, datasources, repository impls + their providers
    │   ├── data.dart               # barrel
    │   └── repositories/           # <name>_repository_impl.dart
    └── presentation/
        ├── theme/                  # app theme (barrel theme.dart)
        ├── widgets/                # widgets used by 2+ pages (barrel widgets.dart)
        ├── hooks/                  # hooks used by 2+ pages (barrel hooks.dart, add when needed)
        └── pages/
            ├── pages.dart          # barrel: exports each <page>_page.dart for the router
            └── <page>/             # one folder per page (home/, my/ …)
                ├── <page>_page.dart        # class <Page>Page, routed from router.dart
                ├── view_models/            # <page>_view_model.dart
                ├── hooks/                  # use_<page>_page.dart, hooks of the page itself
                └── widgets/                # widgets used only by this page
                    └── hooks/              # use_<widget>.dart, hooks of those widgets
```

- No `features/` or `core/` folders. Domain and data are app-wide, not per page.
- Dependency direction: presentation → domain ← data (ViewModels may read repository providers from `data/`). `domain/` imports nothing from `data/` or `presentation/`.
- Pages never import each other's files. A widget/hook needed by a second page → move it to `presentation/widgets/` or `presentation/hooks/`.

### Naming

- Screens are **pages**, never "views": `pages/<page>/<page>_page.dart`, class `<Name>Page` (`LoginPage`, not `LoginView`/`LoginScreen`). `ViewModel` keeps its name (MVVM term).

### Custom hooks

- A Page/widget's UI logic (local state, derived values, callbacks, package config objects like `CarouselOptions`) goes into its custom hook; the widget calls the hook once and only renders. Return several values as a named record, e.g. `({int current, CarouselOptions options})`. Need `context` inside a hook → `useContext()`.
- Custom hooks always get their own file, never inline in a page/widget file. Named after the page/widget that calls it: `Example` → `useExample()` in `use_example.dart`.
- Page's hook → `pages/<page>/hooks/`. Widget's hook → the `hooks/` folder next to that widget (`pages/<page>/widgets/hooks/`, or `presentation/widgets/hooks/` for shared widgets).
- Controllers a widget uses (`CarouselSliderController`, `PageController`, `ScrollController`, `TabController`…) are created and owned in that widget's hook (`useMemoized(X.new)` / `usePageController()`…) and returned in its record — never created in `build()` or passed down from the page.
- A hook used by a second page → move to `presentation/hooks/` and export from `presentation/hooks/hooks.dart`.
- Built-in `flutter_hooks` hooks (`useTextEditingController`, `useState`…) are called inside the widget's custom hook. Don't write a custom hook that only renames a single built-in one.

### MVVM (presentation layer)

- **Model** = `domain/` + `data/`. **ViewModel** = `pages/<page>/view_models/`. **View** = `pages/<page>/<page>_page.dart` + its `widgets/`.
- One ViewModel per screen: `LoginViewModel` (`@riverpod class LoginViewModel extends _$LoginViewModel`) ↔ `LoginPage`. Its state is a `@freezed` `LoginState` in the same file, or `AsyncValue<T>` when it's just loading one thing.
- ViewModel: holds screen state, exposes intent methods (`signIn()`, `refresh()`), calls repositories via `ref.read(xRepositoryProvider)`. No `BuildContext`, no widgets, no `material.dart` import.
- Page: `ref.watch(loginViewModelProvider)` to render, `ref.read(loginViewModelProvider.notifier).signIn(...)` on events. No business logic, no repository calls. Navigation/snackbars/dialogs stay in the Page (react with `ref.listen`).
- Ephemeral UI-only state (text controllers, animation, focus, a toggle that nothing else reads) → hooks in the Page/widget, not the ViewModel.
- A ViewModel never watches another screen's ViewModel. State shared by several screens → a separate provider (repository-backed in `data/`, or under `presentation/`), watched by each ViewModel.
- DI via Riverpod providers (no get_it). UseCases and separate Entity/DTO are optional — add them only when there's real logic or the shapes diverge.

### Barrel files

- Barrels: `domain/domain.dart`, `data/data.dart`, `presentation/theme/theme.dart`, `presentation/widgets/widgets.dart`, `presentation/hooks/hooks.dart`, `presentation/pages/pages.dart` — `export` lines only.
- `pages.dart` exports only the `<page>_page.dart` files (for the router); a page's view models, hooks and widgets stay private to it.
- Import from outside the folder → through the barrel with a package import (`import 'package:weus/src/domain/domain.dart';`). Inside the same folder/page → direct relative imports, never its own barrel (circular imports).
- Never export generated `*.g.dart` / `*.freezed.dart` (they're `part` files).
- When adding a public file, add its `export` to the barrel in the same change.

### Code style

- Put one blank line between sibling code blocks so the code is easy to scan:
  - between statements in a function body (`final a = …;` ↵ blank ↵ `final b = …;` ↵ blank ↵ `return …;`)
  - between sibling widgets in `children:` / `items:` / `branches:` lists
- Keep a widget's own named arguments (`padding:`, `child:` …) together without blank lines. `dart format` keeps the blank lines.

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

<!-- 프로젝트 규칙을 여기에 추가하세요. 예:
- 응답은 한국어로
- 상태관리는 Riverpod 사용
- 화면 파일은 lib/screens/ 에 둔다
-->
