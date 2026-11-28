---
name: new-page
description: weus 앱에 새 페이지(화면)를 추가할 때 쓴다. 페이지 폴더, 훅, ViewModel, barrel, 라우트, pages.dart export까지 빠짐없이 만든다. "새 페이지", "화면 추가", "/new-page <이름>" 요청에 사용.
---

# 새 페이지 추가

인자: 페이지 이름(snake_case, 예: `group_member`)과 라우트 위치(어느 탭 아래, 전체 화면/시트). 모르면 먼저 묻는다.

`pages/my_info/`가 가장 작은 완성 예시다. 같은 모양으로 만든다.

## 만들 파일

```
lib/src/presentation/pages/<page>/
├── <page>.dart                     # barrel: export "<page>_page.dart"; 만
├── <page>_page.dart                # UI만 (HookConsumerWidget / ConsumerWidget / StatelessWidget)
├── hooks/
│   ├── hooks.dart                  # barrel
│   └── use_<page>_page.dart        # use<Page>Page(ref, …) → named record
├── view_models/                    # 상태·repository 호출이 있을 때만
│   ├── view_models.dart            # barrel
│   └── <page>_view_model.dart      # @riverpod class <Page>ViewModel
└── widgets/                        # 이 페이지 전용 위젯이 있을 때만
    ├── widgets.dart                # barrel
    ├── <widget>.dart               # 파일당 위젯 하나
    └── hooks/                      # 위젯 훅이 있을 때만 (+ hooks.dart barrel)
```

## 순서

1. 위 파일을 만든다. 규칙은 `.claude/rules/presentation.md`, `architecture.md`를 따른다 (build엔 UI만, 로직은 훅, 위젯 1파일, Lucide 아이콘, 한글 주석, 빈 줄 스타일).
2. `lib/src/presentation/pages/pages.dart`에 `export "<page>/<page>.dart";`를 알파벳 순서로 추가한다.
3. `lib/src/router/app_router.dart`에 라우트를 추가한다 (`.claude/rules/router.md`).
   - 탭 위 전체 화면: 그 탭의 `routes:` 아래 `GoRoute` + `parentNavigatorKey: rootKey` + `pageBuilder: (_, state) => CupertinoPage(key: state.pageKey, child: …)`. 헬퍼 없이 매번 써 준다.
   - 아래에서 올라오는 시트: `SheetPage` / 내용만큼 바텀시트: `bottom_sheet_page.dart`.
   - 열 때는 `context.go` (다른 탭 위에 쌓을 때만 `context.push`).
4. 공용 위젯·훅이 새로 필요하면 `presentation/widgets/`·`presentation/hooks/`에 두고 그 barrel에 export한다.
5. `@riverpod`/`@freezed`를 썼으면 `dart run build_runner build -d` (fvm 경로 주의).
6. `flutter analyze`로 확인한다. 앱 실행·리로드는 사용자가 한다.
