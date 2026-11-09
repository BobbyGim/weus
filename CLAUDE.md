# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Dart SDK ^3.13.5. Currently the default Flutter template; `lib/main.dart` is the only source file.

- Routing: `go_router` (installed, not yet wired up — `MaterialApp` still used).
- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`). `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`.
- After changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, regenerate: `dart run build_runner build -d` (or `watch -d`).
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
- Native splash is background color only (Android 12 icon hidden with `transparent.png`); `lib/splash_page.dart` draws the logo (vector paths in `LogoPainter`) then `go('/home')`. `test/goldens/logo.png` is the painter at 1:1 with the source PNG; refresh with `flutter test --update-goldens`.
- Android `compileSdk = 37` (required by `permission_handler`); `android.suppressUnsupportedCompileSdk=37` silences the AGP warning.

## Commands

```bash
flutter pub get                        # install deps
flutter pub add <pkg>                  # add a dependency
flutter run                            # run on connected device/emulator
flutter analyze                        # lint
dart format .                          # format
flutter test                           # all tests
flutter test test/widget_test.dart     # single file
flutter test --plain-name "<name>"     # single test by name
```

## Git

Remote is `https://BobbyGim@github.com/BobbyGim/weus.git` — the username in the URL makes git use the BobbyGim keychain credential (the machine's default GitHub account is a different one). Don't change the remote URL.

## Rules

- UI 작업(화면/위젯 디자인, 리디자인)을 할 때는 `taste-skill:design-taste-frontend` 스킬을 먼저 로드해서 따른다.
- 코드를 작성/수정/리팩터링할 때는 `ponytail:ponytail` 스킬을 적용한다.

<!-- 프로젝트 규칙을 여기에 추가하세요. 예:
- 응답은 한국어로
- 상태관리는 Riverpod 사용
- 화면 파일은 lib/screens/ 에 둔다
-->
