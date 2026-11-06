# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Dart SDK ^3.13.5. Currently the default Flutter template; `lib/main.dart` is the only source file.

- Routing: `go_router` (installed, not yet wired up — `MaterialApp` still used).
- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`). `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`.
- After changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, regenerate: `dart run build_runner build -d` (or `watch -d`).
- Lints: `flutter_lints` via `analysis_options.yaml`; `android/` and `ios/` are excluded from analysis.

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
