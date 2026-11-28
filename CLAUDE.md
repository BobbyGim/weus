# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`weus` — Flutter app (Android/iOS only), Flutter 3.50, Dart SDK ^3.14.0. `lib/main.dart` (bootstrap, `MyApp`), `lib/src/` (router, domain, data, presentation), and `main_<flavor>.dart` entry files.

- State: Riverpod 3 with codegen (`@riverpod` + `riverpod_generator`); `bootstrap()` wraps the app in `ProviderScope`. `riverpod_lint` is enabled as an analyzer plugin in `analysis_options.yaml`.
- Models: `freezed` + `json_serializable`. Routing: `go_router`. Hooks: `flutter_hooks` + `hooks_riverpod`. Local DB: drift.
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.gen.dart`) are gitignored — after a fresh clone or pull, and after changing any `@riverpod` / `@freezed` / `@JsonSerializable` code, run `dart run build_runner build -d` (or `watch -d`).
- Lints: `flutter_lints` via `analysis_options.yaml`; `android/` and `ios/` are excluded from analysis.

## Where the rest lives

상황별 규칙은 해당 파일을 만질 때만 읽히도록 나눠 두었다. README.md에는 설치·실행·빌드와 이 표의 링크만 있다. 규칙을 바꿀 때는 이 파일들만 고친다.

| 파일 | 언제 읽히나 | 내용 |
|---|---|---|
| `.claude/rules/architecture.md` | `lib/**` | 레이어, 폴더 구조, 코드 위치, barrel, 코드 스타일 |
| `.claude/rules/presentation.md` | `lib/src/presentation/**` | build엔 UI만, 위젯 1파일, 위젯 종류, 아이콘, 폰트, MVVM, 훅 |
| `.claude/rules/forms.md` | `lib/src/presentation/**` | 키보드 처리 두 방식 |
| `.claude/rules/router.md` | `lib/src/router/**` | 탭·전체 화면·시트 라우트, 딥링크, 딥링크 테스트 |
| `.claude/rules/database.md` | `lib/src/data/**` | drift, 날짜 저장 형식, 스키마 변경 |
| `.claude/rules/flavors.md` | `android/`, `ios/`, `lib/main*.dart`, `pubspec.yaml`, `.env*` | flavor, 아이콘·스플래시, 네이티브 설정 |
| `.claude/skills/new-page/` | 새 페이지 추가 시 | 페이지·훅·VM·barrel·라우트 절차 |
| `.claude/agents/reviewer.md` | 리뷰를 맡길 때 | 규칙 기준 diff 검토 |

## Flavors

| flavor | bundle / applicationId | app name | deep link |
|---|---|---|---|
| dev | `com.weus.weus.dev` | 위어스 dev | `weus-dev://app/<route>` |
| staging | `com.weus.weus.staging` | 위어스 stg | `weus-staging://app/<route>` |
| prod | `com.weus.weus` | 위어스 | `weus://app/<route>` |

`flutter run --flavor staging -t lib/main_staging.dart` — keep `--flavor` and `-t` matching. Plain `flutter run` → `dev`.

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

- UI/UX 작업(화면·위젯 디자인·구현, 리디자인, 애니메이션, 반응형 레이아웃, 테마)을 할 때는 세 스킬을 함께 로드해서 따른다:
  - `ui-ux-pro-max:ui-ux-pro-max`: 팔레트·UX 규칙 근거 (Flutter 스택 가이드 기준)
  - `impeccable:impeccable`: AI 티 나는 패턴 점검과 다듬기 (앱 화면은 Operate 모드)
  - `flutter-ui-ux`: Flutter 구현 가이드
- 코드를 작성/수정/리팩터링할 때는 `ponytail:ponytail` 스킬을 적용한다.
- 테스트 코드(`test/`, 위젯/유닛/골든 테스트 등)는 작성하지 않는다. 검증은 `flutter analyze`와 빌드/실행으로 한다. (ponytail의 "runnable check" 규칙보다 우선)
- 코드 주석(`//`, `///`)의 설명은 한글로 쓴다.
