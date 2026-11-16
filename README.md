# weus

위어스 — Android/iOS용 Flutter 앱입니다.

## Getting Started

### 1. Setup

```bash
flutter pub get
cp .env.example .env.dev && cp .env.example .env.staging && cp .env.example .env.prod
dart run build_runner build -d
```

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

## Architecture Overview

레이어 우선(layer-first) 클린 아키텍처에 MVVM을 얹은 구조입니다.

```
presentation  ──▶  domain  ◀──  data
 (화면, VM)       (인터페이스)    (DB, API, 구현체)
```

- **domain**: Repository 인터페이스. 순수 Dart이고, 다른 레이어를 import하지 않습니다.
- **data**: DB, 네트워크 같은 데이터 소스와 repository 구현체입니다.
- **presentation**: 페이지, ViewModel, 위젯, 훅입니다. Repository는 domain 인터페이스로만 다룹니다.
- domain과 data는 **앱 전체가 함께 씁니다.** 기능별 `features/` 폴더는 없습니다.

## Folder Structure

```
lib/
├── main.dart                 # bootstrap() — 앱 시작 코드는 여기에
├── main_<flavor>.dart        # flavor별 진입점
└── src/
    ├── router/
    │   ├── router.dart             # 라우트 표 (routerProvider)
    │   ├── deep_link_redirect.dart # 딥링크 redirect
    │   └── app_visibility.dart     # 앱이 화면에 보일 때까지 대기 (onScreen)
    ├── utils/                # 어느 레이어에서나 쓰는 순수 Dart 헬퍼
    ├── domain/
    │   ├── entities/
    │   └── repositories/     # <name>_repository.dart (인터페이스)
    ├── data/
    │   ├── database/         # drift DB + provider, tables/ 에 테이블당 파일 하나
    │   ├── network/          # dio + provider (필요할 때 추가)
    │   ├── supabase/         # supabase + provider (필요할 때 추가)
    │   └── repositories/     # <name>_repository_impl.dart
    └── presentation/
        ├── theme/
        ├── widgets/          # 2개 이상 페이지가 쓰는 위젯
        ├── hooks/            # 2개 이상 페이지가 쓰는 훅
        └── pages/
            └── <page>/
                ├── <page>_page.dart
                ├── view_models/
                ├── hooks/
                └── widgets/
                    └── hooks/
```

### Where Does It Go?

| 이런 코드는 | 여기에 |
|---|---|
| 날짜·텍스트 포맷 같은 순수 Dart 헬퍼 | `utils/` (`intl` OK, Flutter·`BuildContext` 금지) |
| `BuildContext`나 위젯이 필요한 헬퍼 | `presentation/` |
| repository 인터페이스 | `domain/repositories/` |
| DB·API 클라이언트와 그 provider | `data/<클라이언트>/` (같은 파일에, `providers/` 폴더 없음) |
| repository 구현체 | `data/repositories/` |
| `Supabase.initialize` 같은 1회성 초기화 | `main.dart`의 `bootstrap()` |
| 한 페이지에서만 쓰는 위젯·훅 | `pages/<page>/widgets/`, `pages/<page>/hooks/` |
| 두 페이지 이상에서 쓰는 위젯·훅 | `presentation/widgets/`, `presentation/hooks/` |

페이지끼리는 서로의 파일을 import하지 않습니다. 다른 페이지에서도 필요해지면 공용 폴더로 옮기세요.

---

## Pages (MVVM)

| 역할 | 위치 | 하는 일 |
|---|---|---|
| **Model** | `domain/`, `data/` | 데이터와 repository |
| **ViewModel** | `pages/<page>/view_models/` | 화면 상태 보관, repository 호출 |
| **View** | `pages/<page>/<page>_page.dart`, `widgets/` | 렌더링, 이벤트 전달, 내비게이션 |

화면 하나에 ViewModel 하나를 둡니다. 예: `LoginPage` ↔ `LoginViewModel`

```dart
// view_models/login_view_model.dart
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  Future<void> signIn() async {
    await ref.read(authRepositoryProvider).signIn(...);
  }
}

// login_page.dart
final state = ref.watch(loginViewModelProvider);

onPressed: () => ref.read(loginViewModelProvider.notifier).signIn(),
```

**ViewModel**
- 상태는 같은 파일의 `@freezed` `LoginState`를 씁니다. 한 가지만 로딩한다면 `AsyncValue<T>`도 됩니다.
- `BuildContext`, 위젯, `material_ui`를 쓰지 않습니다.
- 다른 화면의 ViewModel을 watch하지 않습니다. 여러 화면이 같이 쓰는 상태는 별도 provider로 빼고, 각 ViewModel이 그 provider를 watch합니다.

**Page**
- 비즈니스 로직과 repository 호출은 넣지 않습니다.
- 내비게이션, 스낵바, 다이얼로그는 Page에서 처리합니다 (`ref.listen`).
- 텍스트 컨트롤러, 애니메이션, 포커스처럼 UI에서만 쓰는 상태는 ViewModel이 아니라 훅에 둡니다.

**그 외**
- DI는 Riverpod provider로 합니다 (get_it 없음).
- UseCase나 Entity/DTO 분리는 실제 로직이 있거나 형태가 달라질 때만 추가합니다.

---

## Custom Hooks

페이지와 위젯은 **훅을 한 번 호출하고 렌더링만** 합니다. 로컬 상태, 파생 값, 콜백, 컨트롤러는 모두 훅으로 옮깁니다.

```dart
// widgets/hooks/use_banner.dart
({int current, CarouselOptions options}) useBanner() {
  final current = useState(0);

  final options = CarouselOptions(onPageChanged: (i, _) => current.value = i);

  return (current: current.value, options: options);
}

// widgets/banner.dart
final (:current, :options) = useBanner();
```

- **파일**: 훅마다 파일을 따로 만듭니다. `Banner` 위젯의 훅은 `use_banner.dart`의 `useBanner()`입니다.
- **위치**: 페이지 훅은 `pages/<page>/hooks/`, 위젯 훅은 그 위젯 옆의 `hooks/`에 둡니다.
- **반환**: 값이 여러 개면 named record로 반환합니다.
- **컨트롤러**: `PageController`, `ScrollController` 등은 훅 안에서 만들어 반환합니다 (`useMemoized(X.new)`, `usePageController()`). `build()`에서 만들거나 페이지에서 내려주지 않습니다.
- **context**가 필요하면 `useContext()`를 씁니다.
- `useState` 같은 기본 훅 하나의 이름만 바꾸는 커스텀 훅은 만들지 않습니다.

---

## Barrel Files

폴더마다 `export` 줄만 모아 둔 barrel 파일이 있습니다. 밖에서는 이 파일 하나만 import하면 됩니다.

| Barrel | 모아 두는 것 |
|---|---|
| `lib/src/utils/utils.dart` | 순수 Dart 헬퍼 |
| `lib/src/domain/domain.dart` | entity, repository 인터페이스 |
| `lib/src/data/data.dart` | DB·API 클라이언트 provider, repository 구현체 |
| `lib/src/presentation/theme/theme.dart` | 앱 테마 |
| `lib/src/presentation/widgets/widgets.dart` | 공용 위젯 |
| `lib/src/presentation/hooks/hooks.dart` | 공용 훅 |
| `lib/src/presentation/pages/pages.dart` | 각 `<page>_page.dart` (라우터용) |

| 상황 | import 방법 |
|---|---|
| 폴더 **밖**에서 가져올 때 | barrel로: `import 'package:weus/src/domain/domain.dart';` |
| 같은 폴더·페이지 **안**에서 | 상대 경로로 직접. 자기 barrel은 쓰지 않습니다 (순환 import 방지) |

- 공개 파일을 추가하면 같은 커밋에서 barrel에 `export`도 추가합니다.
- `pages.dart`는 `<page>_page.dart`만 export합니다. 페이지 내부의 VM, 훅, 위젯은 그 페이지 전용입니다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 export하지 않습니다.

---

## Naming

- 화면은 **Page**라고 부릅니다: `LoginPage` (`LoginView`, `LoginScreen`은 쓰지 않음)
- 파일은 `pages/<page>/<page>_page.dart`입니다.
- `ViewModel`은 MVVM 용어 그대로 씁니다.

## Code Style

같은 레벨의 코드 블록 사이에 빈 줄 하나를 둡니다.

```dart
final a = …;

final b = …;

return Column(
  children: [
    const Header(),

    const Body(),
  ],
);
```

- 함수 본문의 문장 사이, 그리고 `children:` / `items:` / `branches:`의 형제 위젯 사이에 적용합니다.
- 위젯 자신의 인자(`padding:`, `child:` …)는 빈 줄 없이 붙여 씁니다.
- `dart format`을 돌려도 빈 줄은 그대로 유지됩니다.
