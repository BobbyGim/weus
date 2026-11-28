# weus

위어스 — Android/iOS용 Flutter 앱입니다.

## Getting Started

### 1. Setup

```bash
flutter pub get
cp .env.example .env.dev && cp .env.example .env.staging && cp .env.example .env.prod
dart run build_runner build -d
```

**코드 생성 (`build_runner`)은 빌드 전에 꼭 실행해야 합니다.** `json_serializable`(JSON 직렬화), `freezed`(모델), `riverpod_generator`(provider), `drift`(DB)가 만드는 생성 파일(`*.g.dart`, `*.freezed.dart`)은 git에 올라가지 않아서, 실행하지 않으면 빌드 에러가 납니다.

- 처음 clone하거나 pull한 뒤에 실행합니다.
- `@JsonSerializable`, `@freezed`, `@riverpod`, drift 테이블을 고친 뒤에도 다시 실행합니다.
- 개발 중에는 `dart run build_runner watch -d`를 켜 두면 저장할 때마다 자동으로 다시 만듭니다.

### 2. Run

```bash
flutter run --flavor dev -t lib/main_dev.dart            # dev (그냥 flutter run 해도 dev)
flutter run --flavor staging -t lib/main_staging.dart    # staging
flutter run --flavor prod -t lib/main_prod.dart          # prod
```

### 3. Build

```bash
# Android (APK)
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor staging -t lib/main_staging.dart
flutter build apk --flavor prod -t lib/main_prod.dart

# Android (스토어 업로드용 App Bundle)
flutter build appbundle --flavor prod -t lib/main_prod.dart

# iOS (IPA)
flutter build ipa --flavor dev -t lib/main_dev.dart
flutter build ipa --flavor staging -t lib/main_staging.dart
flutter build ipa --flavor prod -t lib/main_prod.dart
```

| flavor | 앱 이름 | 번들 ID | 딥링크 |
|---|---|---|---|
| dev | 위어스 dev | `com.weus.weus.dev` | `weus-dev://app/<route>` |
| staging | 위어스 stg | `com.weus.weus.staging` | `weus-staging://app/<route>` |
| prod | 위어스 | `com.weus.weus` | `weus://app/<route>` |

- `--flavor`와 `-t`는 항상 같은 flavor로 맞추세요.
- `.env.*` 파일과 생성 파일(`*.g.dart`, `*.freezed.dart`)은 git에 올라가지 않습니다. 처음 clone하거나 pull한 뒤에는 위 명령을 다시 실행하세요.
- `.env.*` 내용은 앱 번들에 그대로 들어갑니다. 공개해도 되는 값만 넣으세요.

---

## Architecture

레이어 우선(layer-first) 클린 아키텍처에 MVVM을 얹은 구조입니다.

```
presentation  ──▶  domain  ◀──  data
 (화면, VM)       (인터페이스)    (DB, API, 구현체)
```

| 레이어 | 위치 | 하는 일 |
|---|---|---|
| **domain** | `lib/src/domain/` | entity와 repository 인터페이스. 순수 Dart, 다른 레이어를 import하지 않음 |
| **data** | `lib/src/data/` | DB(drift), 네트워크 같은 데이터 소스와 repository 구현체 |
| **presentation** | `lib/src/presentation/` | 페이지, ViewModel, 위젯, 훅. repository는 domain 인터페이스로만 다룸 |

```
lib/
├── main.dart, main_<flavor>.dart
└── src/
    ├── router/          # 라우트 표, redirect
    ├── utils/           # 순수 Dart 헬퍼
    ├── domain/          # entities/, repositories/ (인터페이스)
    ├── data/            # database/, repositories/ (구현체)
    └── presentation/
        ├── theme/, widgets/, hooks/     # 공용
        └── pages/<page>/
            ├── <page>_page.dart         # View: UI만
            ├── view_models/             # ViewModel: 상태, repository 호출
            ├── hooks/                   # 로직: use<Page>Page()
            └── widgets/                 # 이 페이지 전용 위젯
```

- 화면 하나에 ViewModel 하나 (`LoginPage` ↔ `LoginViewModel`), DI는 Riverpod provider.
- 페이지·위젯의 `build`에는 UI만 두고, 로직은 옆 `hooks/`의 훅으로 옮깁니다.
- 폴더마다 같은 이름의 barrel 파일이 있고, 밖에서는 barrel로 import합니다.
- 기능별 `features/` 폴더는 없습니다. domain과 data는 앱 전체가 함께 씁니다.

자세한 규칙은 아래 문서에 있습니다.

## 개발 규칙

규칙은 Claude Code와 사람이 같이 보도록 `.claude/`에 나눠 두었습니다. 같은 내용을 여기에 다시 쓰지 않습니다.

| 문서 | 내용 |
|---|---|
| [CLAUDE.md](CLAUDE.md) | 스택, 명령어, 공통 규칙 |
| [architecture.md](.claude/rules/architecture.md) | 레이어, 폴더 구조, 코드 위치, barrel, 코드 스타일 |
| [presentation.md](.claude/rules/presentation.md) | 페이지·위젯·훅 규칙, MVVM, 아이콘, 폰트, 네이밍 |
| [forms.md](.claude/rules/forms.md) | 입력 화면의 키보드 처리 |
| [router.md](.claude/rules/router.md) | 라우트, 딥링크, 딥링크 테스트 |
| [database.md](.claude/rules/database.md) | drift, 날짜 저장 형식, 스키마 변경 |
| [flavors.md](.claude/rules/flavors.md) | flavor, 앱 아이콘·스플래시, 네이티브 설정 |
| [new-page 스킬](.claude/skills/new-page/SKILL.md) | 새 페이지 추가 절차 |
| [reviewer 에이전트](.claude/agents/reviewer.md) | 변경분 리뷰 기준 |
| [hooks](.claude/hooks/) | 자동 format, Material 아이콘 차단, 턴 종료 시 analyze |
