---
paths:
  - "lib/**/*.dart"
---

# Architecture

레이어 우선(layer-first) 클린 아키텍처 + MVVM.

```
presentation  ──▶  domain  ◀──  data
 (화면, VM)       (인터페이스)    (DB, API, 구현체)
```

- **domain**: Repository 인터페이스. 순수 Dart, 다른 레이어를 import하지 않는다.
- **data**: DB, 네트워크 같은 데이터 소스와 repository 구현체.
- **presentation**: 페이지, ViewModel, 위젯, 훅. Repository는 domain 인터페이스로만 다룬다.
- domain과 data는 앱 전체가 함께 쓴다. 기능별 `features/` 폴더는 없다.

## Folder Structure

```
lib/
├── main.dart                 # bootstrap() — 앱 시작 코드는 여기에
├── main_<flavor>.dart        # flavor별 진입점
└── src/
    ├── router/               # 라우트 표, redirect, 시트 페이지
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

## Where Does It Go?

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

페이지끼리는 서로의 파일을 import하지 않는다. 다른 페이지에서도 필요해지면 공용 폴더로 옮긴다.

- DI는 Riverpod provider로 한다 (get_it 없음).
- UseCase나 Entity/DTO 분리는 실제 로직이 있거나 형태가 달라질 때만 추가한다.

## Barrel Files

폴더마다 `export` 줄만 모아 둔 barrel 파일이 있다.

| Barrel | 모아 두는 것 |
|---|---|
| `lib/src/utils/utils.dart` | 순수 Dart 헬퍼 |
| `lib/src/domain/domain.dart` | entity, repository 인터페이스 |
| `lib/src/data/data.dart` | DB·API 클라이언트 provider, repository 구현체 |
| `lib/src/presentation/theme/theme.dart` | 앱 테마 |
| `lib/src/presentation/widgets/widgets.dart` | 공용 위젯 |
| `lib/src/presentation/hooks/hooks.dart` | 공용 훅 |
| `lib/src/presentation/pages/pages.dart` | 각 `<page>_page.dart` (라우터용) |

- 폴더 **밖**에서 가져올 때는 barrel로 (`import 'package:weus/src/domain/domain.dart';`). 같은 폴더·페이지 **안**에서는 상대 경로로 직접, 자기 barrel은 쓰지 않는다 (순환 import 방지).
- 공개 파일을 추가하면 같은 커밋에서 barrel에 `export`도 추가한다.
- **모든 폴더**에 폴더 이름과 같은 barrel을 둔다 (`data/database/database.dart`, `pages/schedule/widgets/hooks/hooks.dart`). 상위 barrel은 파일 대신 하위 barrel을 export하고, 폴더를 새로 만들면 barrel도 같이 만든다. `lib/src/presentation/presentation.dart`는 `pages`·`theme`·`widgets`를 모은다.
- 다른 폴더의 파일은 그 폴더 barrel로 가져온다 (`import "widgets/widgets.dart";`). 같은 폴더 파일과 상위 폴더 파일은 상대 경로로 직접 가져온다 (자기·상위 barrel은 순환 import).
- 폴더 이름과 같은 이름의 파일이 필요하면 다른 이름으로 짓는다 (`supabase/supabase_client.dart`, `router/app_router.dart`).
- 페이지 barrel(`pages/<page>/<page>.dart`)은 `<page>_page.dart`만 export한다. 페이지 안의 `widgets/`·`hooks/` barrel은 그 페이지 안에서만 쓰고, 페이지 내부의 VM, 훅, 위젯은 그 페이지 전용이다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 export하지 않는다.

## Code Style

같은 레벨의 코드 블록 사이에 빈 줄 하나를 둔다.

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

- 함수 본문의 문장 사이, 그리고 `children:` / `items:` / `branches:`의 형제 위젯 사이에 적용한다.
- 위젯 자신의 인자(`padding:`, `child:` …)는 빈 줄 없이 붙여 쓴다.
- `dart format`을 돌려도 빈 줄은 그대로 유지된다.
