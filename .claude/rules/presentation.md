---
paths:
  - "lib/src/presentation/**/*.dart"
  - "lib/main.dart"
---

# Presentation (pages, widgets, hooks)

## 위젯 규칙

- 페이지·위젯의 `build`에는 UI(위젯 배치, 분기, 스타일)만 둔다. 로직(provider watch/listen, 파생 값, 콜백, 내비게이션, 컨트롤러, 로컬 상태)은 페이지/위젯 옆 `hooks/`의 `use<Name>()` 훅으로 옮기고, `ref`가 필요하면 `use<Name>(ref, …)`로 넘긴다 (예: `useGroupDetailPage(ref, groupId)`). 콜백 하나뿐인 아주 작은 위젯은 예외.
- 파일 하나에 위젯 클래스 하나만 둔다 (private `_Foo` 포함). 메뉴와 그 아이템처럼 함께 쓰는 위젯도 파일을 나눈다 (`home_quick_menu.dart` + `home_quick_menu_item.dart`), 파일 이름은 위젯 이름의 snake_case.
- Hooks: `flutter_hooks` + `hooks_riverpod`. Import `package:hooks_riverpod/hooks_riverpod.dart` (re-exports flutter_riverpod; `flutter_riverpod` is not a direct dependency). Widgets needing `ref` + local state (controllers, animations, focus nodes) → `HookConsumerWidget` with `useTextEditingController()` etc. instead of `ConsumerStatefulWidget`; `ref` only → `ConsumerWidget`; neither → `StatelessWidget`. Shared state stays in providers, not hooks.
- Icons: Lucide only (`lucide_icons_flutter`, `import "package:lucide_icons_flutter/lucide_icons.dart";` → `Icon(LucideIcons.calendarDays)`). Never Material `Icons.*` / `CupertinoIcons.*`, and no Material icon widgets (`CloseButton`, `BackButton` → `IconButton` with a Lucide icon). Lucide has no filled variants: show selected/active state with color, not a second icon.
- Font: Pretendard (400/500/600/700/800/900, `assets/fonts/`, OFL license alongside) is the theme default via `ThemeData(fontFamily: 'Pretendard')`. Other weights fall back to synthesized ones. Every `TextTheme` style sets `FontFeature.tabularFigures()` (all digits same width, app-wide) — keep it when adding styles.

## Naming

- 화면은 **Page**라고 부른다: `LoginPage` (`LoginView`, `LoginScreen`은 쓰지 않음). 파일은 `pages/<page>/<page>_page.dart`.
- `ViewModel`은 MVVM 용어 그대로 쓴다.

## Pages (MVVM)

| 역할 | 위치 | 하는 일 |
|---|---|---|
| **Model** | `domain/`, `data/` | 데이터와 repository |
| **ViewModel** | `pages/<page>/view_models/` | 화면 상태 보관, repository 호출 |
| **View** | `pages/<page>/<page>_page.dart`, `widgets/` | 렌더링, 이벤트 전달, 내비게이션 |

화면 하나에 ViewModel 하나 (`LoginPage` ↔ `LoginViewModel`).

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
- 상태는 같은 파일의 `@freezed` `LoginState`를 쓴다. 한 가지만 로딩한다면 `AsyncValue<T>`도 된다.
- `BuildContext`, 위젯, `material_ui`를 쓰지 않는다.
- 다른 화면의 ViewModel을 watch하지 않는다. 여러 화면이 같이 쓰는 상태는 별도 provider로 빼고, 각 ViewModel이 그 provider를 watch한다.

**Page**
- 비즈니스 로직과 repository 호출은 넣지 않는다.
- 내비게이션, 스낵바, 다이얼로그는 Page에서 처리한다 (`ref.listen`).
- 텍스트 컨트롤러, 애니메이션, 포커스처럼 UI에서만 쓰는 상태는 ViewModel이 아니라 훅에 둔다.

## Custom Hooks

페이지와 위젯은 **훅을 한 번 호출하고 렌더링만** 한다. 로컬 상태, 파생 값, 콜백, 컨트롤러는 모두 훅으로 옮긴다.

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

- **파일**: 훅마다 파일을 따로 만든다. `Banner` 위젯의 훅은 `use_banner.dart`의 `useBanner()`.
- **위치**: 페이지 훅은 `pages/<page>/hooks/`, 위젯 훅은 그 위젯 옆의 `hooks/`.
- **반환**: 값이 여러 개면 named record로 반환한다.
- **컨트롤러**: `PageController`, `ScrollController` 등은 훅 안에서 만들어 반환한다 (`useMemoized(X.new)`, `usePageController()`). `build()`에서 만들거나 페이지에서 내려주지 않는다.
- **context**가 필요하면 `useContext()`를 쓴다.
- `useState` 같은 기본 훅 하나의 이름만 바꾸는 커스텀 훅은 만들지 않는다.
