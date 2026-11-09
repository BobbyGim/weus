# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Dart SDK ^3.13.5. Early stage: `lib/main.dart` (bootstrap, `MyApp`, template home page), `lib/router.dart`, and `main_<flavor>.dart` entry files.

- Routing: `go_router`, exposed as `routerProvider` (`@Riverpod(keepAlive: true)`) in `lib/router.dart`; `MyApp` is a `ConsumerWidget` that watches it. Add routes there. `/` is the home page; no Flutter splash route.
- Hooks: `flutter_hooks` + `hooks_riverpod`. Import `package:hooks_riverpod/hooks_riverpod.dart` (re-exports flutter_riverpod; `flutter_riverpod` is not a direct dependency). Widgets needing `ref` + local state (controllers, animations, focus nodes) → `HookConsumerWidget` with `useTextEditingController()` etc. instead of `ConsumerStatefulWidget`; `ref` only → `ConsumerWidget`; neither → `StatelessWidget`. Shared state stays in providers, not hooks.
- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`); `bootstrap()` wraps the app in `ProviderScope`. Generated `*.g.dart` files are committed. `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`.
- After changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, regenerate: `dart run build_runner build -d` (or `watch -d`).
- Font: Pretendard (400/500/600/700/800/900, `assets/fonts/`, OFL license alongside) is the theme default via `ThemeData(fontFamily: 'Pretendard')`. Other weights fall back to synthesized ones.
- Lints: `flutter_lints` via `analysis_options.yaml`; `android/` and `ios/` are excluded from analysis.

## Flavors (dev / staging / prod)

| flavor | bundle / applicationId | app name |
|---|---|---|
| dev | `com.weus.weus.dev` | 위어스 dev |
| staging | `com.weus.weus.staging` | 위어스 stg |
| prod | `com.weus.weus` | 위어스 |

- `flutter run --flavor staging -t lib/main_staging.dart` (entry files `main_<flavor>.dart` call `bootstrap('<flavor>')` in `main.dart`). Keep `--flavor` and `-t` matching. Plain `flutter run` → `dev` (`default-flavor` in pubspec, env from `appFlavor`).
- App-wide startup code goes in `bootstrap()` in `lib/main.dart`, not in the per-flavor entry files.
- Android: `productFlavors` in `android/app/build.gradle.kts`, label via `resValue("string","app_name")`.
- iOS: build configs `Debug-<flavor>` / `Release-<flavor>` / `Profile-<flavor>` + schemes `dev`/`staging`/`prod`. Bundle id and `APP_DISPLAY_NAME` (→ `CFBundleDisplayName`) are set per config in `project.pbxproj`. Adding a flavor means adding all three configs + a scheme.
- Env: `main.dart` loads `.env.$appFlavor` via `flutter_dotenv`. `.env.*` files are gitignored but declared as assets, so **a fresh clone must create `.env.dev`, `.env.staging`, `.env.prod` from `.env.example` before building**. Everything in them ships inside the app bundle — no real secrets.
- Icons & splash per flavor: prod = light (white bg, dark logo), dev/staging = inverted (dark `#111111` bg, white logo). Sources in `assets/logo/`; configs `flutter_launcher_icons-<flavor>.yaml` / `flutter_native_splash-<flavor>.yaml`. Regenerate with `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create --flavors dev,staging,prod`. iOS configs point at `AppIcon-<flavor>` and `LAUNCH_SCREEN_STORYBOARD=LaunchScreen<Flavor>` (Info.plist uses `$(LAUNCH_SCREEN_STORYBOARD)`); re-running the splash generator does not touch these.
- Splash is native only (no Flutter splash page): logo `splash_<light|dark>.png` (@4x, 180pt) + bottom wordmark `branding_<light|dark>.png` ("WeUs"); Android 12 uses `splash_a12_*.png` (1152px, logo kept inside the icon circle). If startup work is added (e.g. auth check), keep the native splash up with `FlutterNativeSplash.preserve()` / `remove()` instead of adding a splash route, so deep links land directly on their page.
- Android `compileSdk = 37` (required by `permission_handler`); `android.suppressUnsupportedCompileSdk=37` silences the AGP warning.

## Architecture (feature-first clean architecture)

```
lib/
├── core/                 # shared: widgets/, theme/, extensions/, utils/, network/, error/
└── features/<feature>/
    ├── domain/           # entities, repository interfaces (pure Dart, no Flutter/data imports)
    ├── data/             # DTOs, datasources, repository impls
    └── presentation/     # @riverpod providers, pages, widgets
```

- Dependency direction: presentation → domain ← data. `features/*` → `core`; `core` never imports `features`. Features never import each other — move the shared piece to `core/` instead.
- A widget used by one feature stays in that feature's `presentation/widgets/`; move it to `core/widgets/` only once a second feature needs it.
- DI via Riverpod providers (no get_it). UseCases and separate Entity/DTO are optional — add them only when there's real logic or the shapes diverge.

### Barrel files

- Each `core/` subfolder and each feature has one barrel: `core/widgets/widgets.dart`, `features/auth/auth.dart`, etc. — `export` lines only.
- A feature barrel exports only what other code needs (pages for the router, public providers). Don't export data-layer internals.
- Import from outside the folder → through the barrel (`import 'package:weus/core/widgets/widgets.dart';`). Inside the same feature/folder → direct relative imports, never its own barrel (circular imports).
- Never export generated `*.g.dart` / `*.freezed.dart` (they're `part` files).
- When adding a public file, add its `export` to the barrel in the same change.

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
- 코드를 작성/수정/리팩터링할 때는 `ponytail:ponytail` 스킬을 적용한다.
- 테스트 코드(`test/`, 위젯/유닛/골든 테스트 등)는 작성하지 않는다. 검증은 `flutter analyze`와 빌드/실행으로 한다. (ponytail의 "runnable check" 규칙보다 우선)

<!-- 프로젝트 규칙을 여기에 추가하세요. 예:
- 응답은 한국어로
- 상태관리는 Riverpod 사용
- 화면 파일은 lib/screens/ 에 둔다
-->
